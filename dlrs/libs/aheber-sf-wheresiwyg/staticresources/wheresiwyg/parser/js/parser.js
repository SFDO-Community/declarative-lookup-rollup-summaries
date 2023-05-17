let lang = "soql";
let parser;
const CURSOR_MOVE_DIRECTION = {
  down: "down",
  up: "up",
  over: "over",
  eof: "eof"
};
const NODE_TYPES = {
  where_clause: "where_clause",
  comparison_expression: "comparison_expression",
  function_expression: "function_expression",
  field_identifier: "field_identifier",
  dotted_identifier: "dotted_identifier",
  identifier: "identifier",
  and_expression: "and_expression",
  or_expression: "or_expression",
  not_expression: "not_expression"
};

async function init() {
  await TreeSitter.init();
  parser = new TreeSitter();

  let langData = `js/tree-sitter-soql.wasm`;
  if ("object" !== typeof window) {
    // make loadable on NodeJS to enable testing, should be smarter later
    const fs = require("fs");
    langData = fs.readFileSync(
      "dlrs/main/staticresources/SOQL_Parser/parser/js/tree-sitter-soql.wasm"
    );
  }
  try {
    lang = await TreeSitter.Language.load(langData);
    parser.setLanguage(lang);
  } catch (e) {
    console.error(e);
    return;
  }
}

function processQuery(whereClause) {
  if (!whereClause || whereClause.trim().length === 0) {
    return {};
  }
  const queryString = `SELECT Id FROM User WHERE ${whereClause}`;
  const newTree = parser.parse(queryString);
  const processedTree = transformTree(newTree);
  return processedTree;
}

function transformTree(tree) {
  const parseResults = {
    // fields relative to the base object
    referencedFields: [],
    filterLogic: "",
    filters: []
  };
  // TODO: find and report errors
  const cursor = tree.walk();
  try {
    advanceCursorToWhereClause(cursor);
  } catch (error) {
    console.error(error);
    // didn't find a where_clause, likely because what we received wasn't a valid where_clause
  }

  // build AND/OR/NOT clauses
  let expCount = 0;
  let stacks = [
    { stackType: "AND", expressions: [], lastNode: cursor.endIndex }
  ];
  let filterLogic = "";

  function buildStack(stack) {
    // TODO: clean up the logic paths here
    if (stack.stackType === "NOT") {
      filterLogic = `NOT ${stack.expressions[0]}`;
    } else {
      filterLogic = `${stack.expressions.join(` ${stack.stackType} `)}`;
    }

    if (stacks.length > 0) {
      // add as nested condition on the parent logic
      stacks[stacks.length - 1].expressions.push(`(${filterLogic})`);
    }
  }
  let lastComparisonEndIndex;
  while (advanceCursor(cursor) !== CURSOR_MOVE_DIRECTION.eof) {
    if (lastComparisonEndIndex && lastComparisonEndIndex >= cursor.endIndex) {
      // ensure we go past the last Comparison Expression
      // was a problem with sub-queries because we would see them
      // at the top comparison then we might dive into the sub-query and falsely
      // build another comparison expression that isn't actually part of the query "structure"
      continue;
    }
    if (
      stacks.length > 1 &&
      stacks[stacks.length - 1].lastNode < cursor.startIndex
    ) {
      buildStack(stacks.pop());
    }
    switch (cursor.nodeType) {
      case NODE_TYPES.comparison_expression:
        expCount++;
        lastComparisonEndIndex = cursor.endIndex;
        stacks[stacks.length - 1].expressions.push(expCount);
        parseResults.filters.push({
          num: expCount,
          ...getComparisonExpression(cursor)
        });
        break;
      case NODE_TYPES.and_expression:
        stacks.push({
          stackType: "AND",
          expressions: [],
          lastNode: cursor.endIndex
        });
        break;
      case NODE_TYPES.or_expression:
        stacks.push({
          stackType: "OR",
          expressions: [],
          lastNode: cursor.endIndex
        });
        break;
      case NODE_TYPES.not_expression:
        stacks.push({
          stackType: "NOT",
          expressions: [],
          lastNode: cursor.endIndex
        });
        break;
      default:
    }
  }

  // build outer-most relationships
  if (stacks[0].expressions.length === 0) {
    stacks.shift();
  }
  while (stacks.length >= 1) {
    buildStack(stacks.pop());
  }
  if (stacks.length > 0) {
    const finishedStack = stacks.pop();
    if (filterLogic.trim().length > 0) {
      finishedStack.expressions.push(filterLogic);
    }
    filterLogic = `${finishedStack.expressions.join(
      ` ${finishedStack.stackType} `
    )}`;
  }
  parseResults.filterLogic = filterLogic;
  cursor.delete();
  // dedup and flatten a little bit
  parseResults.referencedFields = [
    ...new Set(
      parseResults.filters.map((f) => JSON.stringify(f.referencedFields))
    )
  ]
    .map((f) => JSON.parse(f))
    .flat();
  return parseResults;
}

function advanceCursor(cursor) {
  // if has children, go to next child, return 'down'
  if (cursor.gotoFirstChild()) {
    return CURSOR_MOVE_DIRECTION.down;
  }
  // else, got to next sibling, return 'over'
  if (cursor.gotoNextSibling()) {
    return CURSOR_MOVE_DIRECTION.over;
  }
  // else, step backwards to parent, return 'up'
  cursor.gotoParent();
  // while there aren't next siblings, keep stepping up
  while (!cursor.gotoNextSibling()) {
    if (!cursor.gotoParent()) {
      return CURSOR_MOVE_DIRECTION.eof;
    }
  }
  return CURSOR_MOVE_DIRECTION.up;
}

function getComparisonExpression(cursor) {
  const output = {
    // Capture field identifiers as an array, so if it uses a relationship field it is a two-piece array
    referencedFields: [],
    subjects: [],
    operator: undefined,
    values: []
  };
  advanceCursor(cursor);

  function getFieldIdentifiers() {
    const lastIndex = cursor.endIndex;
    let identifierGroup = [];
    while (
      advanceCursor(cursor) !== CURSOR_MOVE_DIRECTION.eof &&
      cursor.startIndex <= lastIndex
    ) {
      switch (cursor.nodeType) {
        case NODE_TYPES.identifier:
          identifierGroup.push(cursor.nodeText);
          break;
        case NODE_TYPES.dotted_identifier:
          // go down and get nested identifiers
          advanceCursor(cursor);
          do {
            if (cursor.nodeType === NODE_TYPES.identifier) {
              identifierGroup.push(cursor.nodeText);
            }
          } while (cursor.gotoNextSibling());
          break;
        default:
      }
    }
    return identifierGroup;
  }

  // get the subject text of the comparision
  if (cursor.nodeType === NODE_TYPES.field_identifier) {
    const identifiers = getFieldIdentifiers();
    output.subjects = identifiers;
    output.referencedFields.push(identifiers);
  } else {
    output.subjects.push(cursor.nodeText);
    // capture the ending position of this node so we can inspect all the children
    const lastIndex = cursor.endIndex;
    // Capture all nested referenced fields, if any
    do {
      if (cursor.nodeType === NODE_TYPES.field_identifier) {
        // get the attributes, populate subjects and figure out how to capture field references
        output.referencedFields.push(getFieldIdentifiers());
      }
    } while (
      cursor.startIndex <= lastIndex &&
      advanceCursor(cursor) !== CURSOR_MOVE_DIRECTION.eof
    );
  }
  output.operator = cursor.nodeText.toUpperCase();
  while (cursor.gotoNextSibling()) {
    if (cursor.nodeIsNamed) {
      output.values.push(cursor.nodeText);
    }
  }

  return output;
}

function advanceCursorToWhereClause(cursor) {
  // TODO: see if I can do this easily using a 'query'
  let movement;
  do {
    movement = advanceCursor(cursor);
    if (movement === CURSOR_MOVE_DIRECTION.eof) {
      throw new Error('Unable to find "where_clause"');
    }
  } while (cursor.nodeType !== NODE_TYPES.where_clause);
  cursor.gotoFirstChild();
}

function assembleQuery(clauseBreakdown) {
  // for each filter, create a comparison statement
  const comparisons = clauseBreakdown.filters.map((f) => assembleComparison(f));

  // take the comparisons and rebuild the larger query according to filterLogic
  let finalQuery = [];
  const digitsRegExp = /(\d+)/g;

  // TODO: error on repeat digits and unused comparisons

  // step through each character, grouping numbers
  for (let p of clauseBreakdown.filterLogic.split(digitsRegExp)) {
    if (digitsRegExp.test(p)) {
      if (comparisons.length < p - 1) {
        throw new Error("invalid comparison number");
      }
      finalQuery.push(comparisons[p - 1]);
    } else {
      finalQuery.push(p);
    }
  }

  return finalQuery.join("");
}

const GROUP_OPERATORS = ["IN", "NOT IN", "INCLUDES", "EXCLUDES"];
function assembleComparison(filter) {
  let queryPart = filter.subjects.join(".");
  queryPart += ` ${filter.operator} `;
  let values = filter.values.map((v) => v.trim()).join(",");
  if (
    GROUP_OPERATORS.includes(filter.operator.toUpperCase()) &&
    !values.trim().startsWith("(")
  ) {
    values = `(${values})`;
  }
  queryPart += values;
  return queryPart;
}

// only run this in the browser
if ("object" === typeof window) {
  init();
  window.addEventListener(
    "message",
    (event) => {
      console.log("Message Received", event);
      let returnData = {};
      if (event.data.query) {
        returnData.filterConfig = processQuery(event.data.query);
      }
      if (event.data.filterConfig) {
        returnData.query = assembleQuery(event.data.filterConfig);
      }
      // post message back with results.
      window.parent.postMessage(returnData, "*");
    },
    false
  );
} else {
  module.exports = { init, processQuery, assembleQuery };
}
