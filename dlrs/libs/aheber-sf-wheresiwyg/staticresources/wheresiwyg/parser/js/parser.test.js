const fs = require("fs");
global.TreeSitter = require("./tree-sitter");
const Parser = require("./parser");
// hacks on hacks
global.fetch = jest.fn((url) => {
  return fs.promises.readFile(url);
});

describe("parser criteria statements", () => {
  beforeAll(async () => {
    // Initialize the parser
    await Parser.init();
  });

  it("Incomplete Data", async () => {
    // Act
    const output = Parser.processQuery("Name");

    // Assert
    // TODO: will probably want some kind of "error" return eventually so the editor knows to enter "Advanced" mode
    expect(output).toBeDefined();
    expect(output.filters).toBeDefined();
  });

  it("Simple WHERE Clause", async () => {
    // Act
    const originalQuery = "Name = 'hello'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        }
      ],
      referencedFields: [["Name"]]
    });

    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Two-part field reference", async () => {
    // Act
    const originalQuery = "CreatedBy.Name = 'hello'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["CreatedBy", "Name"]],
          subjects: ["CreatedBy", "Name"],
          values: ["'hello'"]
        }
      ],
      referencedFields: [["CreatedBy", "Name"]]
    });

    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Function in Field Reference", async () => {
    // Act
    const originalQuery = "toLabel(CreatedById) = 'hello'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["CreatedById"]],
          subjects: ["toLabel(CreatedById)"],
          values: ["'hello'"]
        }
      ],
      referencedFields: [["CreatedById"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Function in Function Field Reference", async () => {
    // Act
    const originalQuery = "toLabel(toLabel(CreatedById)) = 'hello'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["CreatedById"]],
          subjects: ["toLabel(toLabel(CreatedById))"],
          values: ["'hello'"]
        }
      ],
      referencedFields: [["CreatedById"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("IN Clause", async () => {
    // Act
    const originalQuery = "Name IN ('hello','world')";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "IN",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'", "'world'"]
        }
      ],
      referencedFields: [["Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("NOT IN Clause", async () => {
    // Act
    const originalQuery = "Name NOT IN ('hello','world')";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "NOT IN",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'", "'world'"]
        }
      ],
      referencedFields: [["Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Boolean", async () => {
    // Act
    const originalQuery = "IsActive != TRUE";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "!=",
          referencedFields: [["IsActive"]],
          subjects: ["IsActive"],
          values: ["TRUE"]
        }
      ],
      referencedFields: [["IsActive"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Integer", async () => {
    // Act
    const originalQuery = "Total > 100";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: ">",
          referencedFields: [["Total"]],
          subjects: ["Total"],
          values: ["100"]
        }
      ],
      referencedFields: [["Total"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Date1", async () => {
    // Act
    const originalQuery = "Date1__c < 2000-01-01";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "<",
          referencedFields: [["Date1__c"]],
          subjects: ["Date1__c"],
          values: ["2000-01-01"]
        }
      ],
      referencedFields: [["Date1__c"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("DateTime1", async () => {
    // Act
    const originalQuery = "Date1__c = 1999-01-01T23:01:01+01:00";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Date1__c"]],
          subjects: ["Date1__c"],
          values: ["1999-01-01T23:01:01+01:00"]
        }
      ],
      referencedFields: [["Date1__c"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Date Literal", async () => {
    // Act
    const originalQuery = "Date1__c = YESTERDAY";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Date1__c"]],
          subjects: ["Date1__c"],
          values: ["YESTERDAY"]
        }
      ],
      referencedFields: [["Date1__c"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Date Literal w/ Param", async () => {
    // Act
    const originalQuery = "Date1__c = NEXT_N_WEEKS:100";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Date1__c"]],
          subjects: ["Date1__c"],
          values: ["NEXT_N_WEEKS:100"]
        }
      ],
      referencedFields: [["Date1__c"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Currency Literal", async () => {
    // Act
    const originalQuery = "Amount > USD5000";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: ">",
          referencedFields: [["Amount"]],
          subjects: ["Amount"],
          values: ["USD5000"]
        }
      ],
      referencedFields: [["Amount"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Null", async () => {
    // Act
    const originalQuery = "Amount = NULL";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Amount"]],
          subjects: ["Amount"],
          values: ["NULL"]
        }
      ],
      referencedFields: [["Amount"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("MSP =", async () => {
    // Act
    const originalQuery = "MSP1__c = 'AAA;BBB'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["MSP1__c"]],
          subjects: ["MSP1__c"],
          values: ["'AAA;BBB'"]
        }
      ],
      referencedFields: [["MSP1__c"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("MSP INCLUDES", async () => {
    // Act
    const originalQuery = "MSP1__c INCLUDES ('AAA;BBB','CCC')";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "INCLUDES",
          referencedFields: [["MSP1__c"]],
          subjects: ["MSP1__c"],
          values: ["'AAA;BBB'", "'CCC'"]
        }
      ],
      referencedFields: [["MSP1__c"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("MSP EXCLUDES", async () => {
    // Act
    const originalQuery = "MSP1__c EXCLUDES ('AAA;BBB','CCC')";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "EXCLUDES",
          referencedFields: [["MSP1__c"]],
          subjects: ["MSP1__c"],
          values: ["'AAA;BBB'", "'CCC'"]
        }
      ],
      referencedFields: [["MSP1__c"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Decimal", async () => {
    // Act
    const originalQuery = "Name = 15.0";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["15.0"]
        }
      ],
      referencedFields: [["Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Semi-Join", async () => {
    // Act
    const originalQuery = `Id IN ( SELECT AccountId
      FROM Opportunity
      WHERE StageName = 'Closed Lost'
    )`;
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1",
      filters: [
        {
          num: 1,
          operator: "IN",
          referencedFields: [["Id"]],
          subjects: ["Id"],
          values: [
            `( SELECT AccountId
      FROM Opportunity
      WHERE StageName = 'Closed Lost'
    )`
          ]
        }
      ],
      referencedFields: [["Id"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });
});

describe("parser AND/OR/NOT logic", () => {
  beforeAll(async () => {
    // Initialize the parser
    await Parser.init();
  });

  it("Simple Multiple AND Clauses", async () => {
    // Act
    const originalQuery = "Name = 'hello' AND Name != 'blarg'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1 AND 2",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        },
        {
          num: 2,
          operator: "!=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'blarg'"]
        }
      ],
      referencedFields: [["Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Simple Multiple AND Clauses 2", async () => {
    // Act
    const originalQuery =
      "Name = 'hello' AND Name != 'blarg' AND CreatedBy.Name LIKE 'Robot%'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1 AND 2 AND 3",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        },
        {
          num: 2,
          operator: "!=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'blarg'"]
        },
        {
          num: 3,
          operator: "LIKE",
          referencedFields: [["CreatedBy", "Name"]],
          subjects: ["CreatedBy", "Name"],
          values: ["'Robot%'"]
        }
      ],
      referencedFields: [["Name"], ["CreatedBy", "Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Simple Multiple OR Clauses", async () => {
    // Act
    const originalQuery = "Name = 'hello' OR Name != 'blarg'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1 OR 2",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        },
        {
          num: 2,
          operator: "!=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'blarg'"]
        }
      ],
      referencedFields: [["Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("Simple Multiple OR Clauses 2", async () => {
    // Act
    const originalQuery =
      "Name = 'hello' OR Name != 'blarg' OR CreatedBy.Name LIKE 'Robot%'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1 OR 2 OR 3",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        },
        {
          num: 2,
          operator: "!=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'blarg'"]
        },
        {
          num: 3,
          operator: "LIKE",
          referencedFields: [["CreatedBy", "Name"]],
          subjects: ["CreatedBy", "Name"],
          values: ["'Robot%'"]
        }
      ],
      referencedFields: [["Name"], ["CreatedBy", "Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("OR nested in AND", async () => {
    // Act
    const originalQuery =
      "Name = 'hello' AND (Name != 'blarg' OR CreatedBy.Name LIKE 'Robot%')";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1 AND (2 OR 3)",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        },
        {
          num: 2,
          operator: "!=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'blarg'"]
        },
        {
          num: 3,
          operator: "LIKE",
          referencedFields: [["CreatedBy", "Name"]],
          subjects: ["CreatedBy", "Name"],
          values: ["'Robot%'"]
        }
      ],
      referencedFields: [["Name"], ["CreatedBy", "Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("logical NOT", async () => {
    // Act
    const originalQuery = "NOT LastName = 'World'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "NOT 1",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["LastName"]],
          subjects: ["LastName"],
          values: ["'World'"]
        }
      ],
      referencedFields: [["LastName"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("logical NOT in AND", async () => {
    // Act
    const originalQuery = "FirstName = 'Hello' AND (NOT LastName = 'World')";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1 AND (NOT 2)",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["FirstName"]],
          subjects: ["FirstName"],
          values: ["'Hello'"]
        },
        {
          num: 2,
          operator: "=",
          referencedFields: [["LastName"]],
          subjects: ["LastName"],
          values: ["'World'"]
        }
      ],
      referencedFields: [["FirstName"], ["LastName"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });

  it("logical Deep Nesting", async () => {
    // Act
    const originalQuery =
      "Name = 'hello' AND (Name = 'hello' OR (NOT Name = 'Blarg') OR (Name = 'hello' AND Name = 'blarg')) AND Name = 'hello'";
    const output = Parser.processQuery(originalQuery);

    // Assert
    expect(output).toMatchObject({
      filterLogic: "1 AND (2 OR (NOT 3) OR (4 AND 5)) AND 6",
      filters: [
        {
          num: 1,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        },
        {
          num: 2,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        },
        {
          num: 3,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'Blarg'"]
        },
        {
          num: 4,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        },
        {
          num: 5,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'blarg'"]
        },
        {
          num: 6,
          operator: "=",
          referencedFields: [["Name"]],
          subjects: ["Name"],
          values: ["'hello'"]
        }
      ],
      referencedFields: [["Name"]]
    });
    const query = Parser.assembleQuery(output);
    expect(query).toBe(originalQuery);
  });
});
