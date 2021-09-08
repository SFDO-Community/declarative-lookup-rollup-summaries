/**
 * Copyright (c) 2014, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
@isTest
public with sharing class fflib_MatchTest
{
	@isTest
	private static void whenMatchesAllArgsWithOneMatchReturnsTrue()
	{
		//Given
		fflib_MethodArgValues argValues = new fflib_MethodArgValues(new List<Object>{ null });
		List<fflib_IMatcher> targetMatchers = new List<fflib_IMatcher>{ new AlwaysMatch() };
		
		//When
		Boolean match = fflib_Match.matchesAllArgs(argValues, targetMatchers);

		//Then
		System.assert(match);
	}
	
	@isTest
	private static void whenMatchesAllArgsWithManyMatchesReturnsTrue()
	{
		//Given
		fflib_MethodArgValues argValues = new fflib_MethodArgValues(new List<Object>{
			null,
			null,
			null,
			null
		});
		
		List<fflib_IMatcher> targetMatchers = new List<fflib_IMatcher>{
			new AlwaysMatch(),
			new AlwaysMatch(),
			new AlwaysMatch(),
			new AlwaysMatch()
		};
		
		//When
		Boolean match = fflib_Match.matchesAllArgs(argValues, targetMatchers);

		//Then
		System.assert(match);
	}
	
	@isTest
	private static void whenMatchesAllArgsWithOneMismatchReturnsFalse()
	{
		//Given
		fflib_MethodArgValues argValues = new fflib_MethodArgValues(new List<Object>{ null });
		List<fflib_IMatcher> targetMatchers = new List<fflib_IMatcher>{ new NeverMatch() };
		
		//When
		Boolean match = fflib_Match.matchesAllArgs(argValues, targetMatchers);

		//Then
		System.assert(!match);
	}
	
	@isTest
	private static void whenMatchesAllArgsWithManyMismatchesReturnsFalse()
	{
		//Given
		fflib_MethodArgValues argValues = new fflib_MethodArgValues(new List<Object>{
			null,
			null,
			null,
			null
		});
		
		List<fflib_IMatcher> targetMatchers = new List<fflib_IMatcher>{
			new NeverMatch(),
			new NeverMatch(),
			new NeverMatch(),
			new NeverMatch()
		};
		
		//When
		Boolean match = fflib_Match.matchesAllArgs(argValues, targetMatchers);

		//Then
		System.assert(!match);
	}
	
	@isTest
	private static void whenMatchesAllArgsWithMatchesAndMismatchesReturnsFalse()
	{
		//Given
		fflib_MethodArgValues argValues = new fflib_MethodArgValues(new List<Object>{
			null,
			null,
			null,
			null
		});
		
		List<fflib_IMatcher> targetMatchers = new List<fflib_IMatcher>{
			new AlwaysMatch(),
			new AlwaysMatch(),
			new NeverMatch(),
			new AlwaysMatch()
		};
		
		//When
		Boolean match = fflib_Match.matchesAllArgs(argValues, targetMatchers);

		//Then
		System.assert(!match);
	}
	
	@isTest
	private static void whenMatchesAllArgsWithNullMethodArgsThrowsException()
	{
		//Given
		fflib_MethodArgValues methodArg = null;
		List<fflib_IMatcher> targetMatchers = new List<fflib_IMatcher>{ new AlwaysMatch() };
		
		//When
		try
		{
			fflib_Match.matchesAllArgs(methodArg, targetMatchers);
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			//Then
			System.assertEquals('MethodArgs cannot be null', e.getMessage());
		}
	}
	
	@isTest
	private static void whenMatchesAllArgsWithNullMethodArgsArgValuesThrowsException()
	{
		//Given
		fflib_MethodArgValues methodArg = new fflib_MethodArgValues(null);
		List<fflib_IMatcher> targetMatchers = new List<fflib_IMatcher>{ new AlwaysMatch() };
		
		//When
		try
		{
			fflib_Match.matchesAllArgs(methodArg, targetMatchers);
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			//Then
			System.assertEquals('MethodArgs.argValues cannot be null', e.getMessage());
		}
	}
	
	@isTest
	private static void whenMatchesAllArgsWithNullMatchersThrowsException()
	{
		//Given
		fflib_MethodArgValues methodArg = new fflib_MethodArgValues(new List<Object>{ 'Test' });
		List<fflib_IMatcher> targetMatchers = null;
		
		//When
		try
		{
			fflib_Match.matchesAllArgs(methodArg, targetMatchers);
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			//Then
			System.assertEquals('Matchers cannot be null', e.getMessage());
		}
	}
	
	@isTest
	private static void whenMatchesAllArgsWithDifferentSizeArgValuesAndMatchersThrowsException()
	{
		//Given
		fflib_MethodArgValues methodArg = new fflib_MethodArgValues(new List<Object>{ 'Test' });
		List<fflib_IMatcher> targetMatchers = new List<fflib_IMatcher>{ new AlwaysMatch(), new AlwaysMatch() };
		
		//When
		try
		{
			fflib_Match.matchesAllArgs(methodArg, targetMatchers);
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			//Then
			String expectedMessage = 'MethodArgs and matchers must have the same count'
				+ ', MethodArgs: (' + methodArg.argValues.size() + ') ' + methodArg.argValues
				+ ', Matchers: (' + targetMatchers.size() + ') ' + targetMatchers;

			System.assertEquals(expectedMessage, e.getMessage());
		}
	}
	
	@isTest
	private static void whenMatchesWithOneMatcherSetsMatchingToTrue()
	{
		//Given
		fflib_IMatcher matcher = new AlwaysMatch();
		
		//When
		fflib_Match.matches(matcher);
		
		//Then
		System.assert(fflib_Match.Matching);
	}
	
	@isTest
	private static void whenMatchesWithOneMatcherRegistersMatcher()
	{
		//Given
		fflib_IMatcher matcher = new AlwaysMatch();
		
		//When
		fflib_Match.matches(matcher);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(matcher === registeredMatchers[0]);
	}
	
	@isTest
	private static void whenMatchesWithOneMatcherReturnsNull()
	{
		//Given
		fflib_IMatcher matcher = new AlwaysMatch();
		
		//When
		Object retval = fflib_Match.matches(matcher);
		
		//Then
		System.assertEquals(null, retval);
	}

	@isTest
	private static void allOfWithNoArgsThrowsException()
	{
		//Given/When
		try
		{
			Object x = fflib_Match.allOf((List<Object>)null);
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			//Then
			System.assertEquals('Must register matchers to combine', e.getMessage());
		}
	}

	@isTest
	private static void allOfWithEmptyArgsThrowsException()
	{
		//Given/When
		try
		{
			Object x = fflib_Match.allOf(new List<Object>{});
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			//Then
			System.assertEquals('Must register matchers to combine', e.getMessage());
		}
	}

	@isTest
	private static void allOfWithoutRegisteringInnerMatchersThrowsException()
	{
		//Given/When
		try
		{
			//Should be using fflib_Match.allOf(new List<Object>{ fflib_Match.myMatcher('Hello') })
			//to register the inner matcher.
			Object x = fflib_Match.allOf(new List<Object>{ 'Hello' });
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			//Then
			String expectedMessage = 'Error reclaiming inner matchers for combined matcher. '
				+ 'Wanted 1 matchers but only got ' + new List<fflib_IMatcher>();
			System.assertEquals(expectedMessage, e.getMessage());
		}
	}
	
	@isTest
	private static void allOfWith2ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.allOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void allOfWith3ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.allOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'), fflib_Match.eq('hello3'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void allOfWith4ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.allOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'), fflib_Match.eq('hello3'), fflib_Match.eq('hello4'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void allOfWithListArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.allOf(new List<Object>{ fflib_Match.eq('hello') });
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void anyOfWith2ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.anyOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void anyOfWith3ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.anyOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'), fflib_Match.eq('hello3'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void anyOfWith4ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.anyOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'), fflib_Match.eq('hello3'), fflib_Match.eq('hello4'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void anyOfWithListArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.anyOf(new List<Object>{ fflib_Match.eq('hello') });
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void isNotRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.isNot(fflib_Match.eq('hello1'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void noneOfWith2ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.noneOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void noneOfWith3ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.noneOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'), fflib_Match.eq('hello3'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void noneOfWith4ArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.noneOf(fflib_Match.eq('hello1'), fflib_Match.eq('hello2'), fflib_Match.eq('hello3'), fflib_Match.eq('hello4'));
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void noneOfWithListArgsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.noneOf(new List<Object>{ fflib_Match.eq('hello') });
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Combined);
	}

	@isTest
	private static void eqRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eq('hello');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqBooleanRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqBoolean(true);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqDateRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqDate(Date.today());
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqDatetimeRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqDatetime(System.now());
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqDecimalRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqDecimal(123);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqDoubleRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqDouble(123);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqIdRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqId('001000000000001AAA');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqIntegerRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqInteger(123);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqListRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqList(new List<String>{ 'hello' });
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqLongRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqLong(123);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqSObjectFieldRegistersCorrectMatcherType()
	{
		//Given/When
		Schema.SObjectField f = Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().get('Id');
		Object x = fflib_Match.eqSObjectField(f);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqSObjectTypeRegistersCorrectMatcherType()
	{
		//Given/When
		Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
		Object x = fflib_Match.eqSObjectType(ot);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	public static void eqStringRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.eqString('hello');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.Eq);
	}

	@isTest
	private static void refEqRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.refEq('hello');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.RefEq);
	}

	@isTest
	private static void anyBooleanRegistersCorrectMatcherType()
	{
		//Given/When
		Boolean x = fflib_Match.anyBoolean();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyBoolean);
	}

	@isTest
	private static void anyDateRegistersCorrectMatcherType()
	{
		//Given/When
		Date x = fflib_Match.anyDate();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyDate);
	}

	@isTest
	private static void anyDatetimeRegistersCorrectMatcherType()
	{
		//Given/When
		Datetime x = fflib_Match.anyDatetime();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyDatetime);
	}

	@isTest
	private static void anyDecimalRegistersCorrectMatcherType()
	{
		//Given/When
		Decimal x = fflib_Match.anyDecimal();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyDecimal);
	}

	@isTest
	private static void anyDoubleRegistersCorrectMatcherType()
	{
		//Given/When
		Double x = fflib_Match.anyDouble();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyDouble);
	}

	@isTest
	private static void anyFieldSetRegistersCorrectMatcherType()
	{
		//Given/When
		Schema.FieldSet x = fflib_Match.anyFieldSet();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyFieldSet);
	}

	@isTest
	private static void anyIdRegistersCorrectMatcherType()
	{
		//Given/When
		Id x = fflib_Match.anyId();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyId);
	}

	@isTest
	private static void anyIntegerRegistersCorrectMatcherType()
	{
		//Given/When
		Integer x = fflib_Match.anyInteger();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyInteger);
	}

	@isTest
	private static void anyListRegistersCorrectMatcherType()
	{
		//Given/When
		List<Object> x = fflib_Match.anyList();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyList);
	}

	@isTest
	private static void anyLongRegistersCorrectMatcherType()
	{
		//Given/When
		Long x = fflib_Match.anyLong();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyLong);
	}

	@isTest
	private static void anyObjectRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.anyObject();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyObject);
	}

	@isTest
	private static void anyStringRegistersCorrectMatcherType()
	{
		//Given/When
		String x = fflib_Match.anyString();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnyString);
	}

	@isTest
	private static void anySObjectRegistersCorrectMatcherType()
	{
		//Given/When
		SObject x = fflib_Match.anySObject();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnySObject);
	}

	@isTest
	private static void anySObjectFieldRegistersCorrectMatcherType()
	{
		//Given/When
		SObjectField x = fflib_Match.anySObjectField();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnySObjectField);
	}

	@isTest
	private static void anySObjectTypeRegistersCorrectMatcherType()
	{
		//Given/When
		SObjectType x = fflib_Match.anySObjectType();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.AnySObjectType);
	}

	@isTest
	private static void dateAfterRegistersCorrectMatcherType()
	{
		//Given/When
		Date x = fflib_Match.dateAfter(Date.today());

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DatetimeAfter);
	}

	@isTest
	private static void dateBeforeRegistersCorrectMatcherType()
	{
		//Given/When
		Date x = fflib_Match.dateBefore(Date.today());

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DatetimeBefore);
	}

	@isTest
	private static void dateBetweenRegistersCorrectMatcherType()
	{
		//Given/When
		Date x = fflib_Match.dateBetween(Date.today(), Date.today());

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DatetimeBetween);
	}

	@isTest
	private static void datetimeAfterRegistersCorrectMatcherType()
	{
		//Given/When
		Datetime x = fflib_Match.datetimeAfter(System.now());

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DatetimeAfter);
	}

	@isTest
	private static void datetimeBeforeRegistersCorrectMatcherType()
	{
		//Given/When
		Datetime x = fflib_Match.datetimeBefore(System.now());

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DatetimeBefore);
	}

	@isTest
	private static void datetimeBetweenRegistersCorrectMatcherType()
	{
		//Given/When
		Datetime x = fflib_Match.datetimeBetween(System.now(), System.now());

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DatetimeBetween);
	}

	@isTest
	private static void decimalBetweenRegistersCorrectMatcherType()
	{
		//Given/When
		Decimal x = fflib_Match.decimalBetween(0, 10);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalBetween);
	}

	@isTest
	private static void decimalLessThanRegistersCorrectMatcherType()
	{
		//Given/When
		Decimal x = fflib_Match.decimalLessThan(0);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalLessThan);
	}

	@isTest
	private static void decimalMoreThanRegistersCorrectMatcherType()
	{
		//Given/When
		Decimal x = fflib_Match.decimalMoreThan(0);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalMoreThan);
	}

	@isTest
	private static void doubleBetweenRegistersCorrectMatcherType()
	{
		//Given/When
		Double x = fflib_Match.doubleBetween(0, 10);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalBetween);
	}

	@isTest
	private static void doubleLessThanRegistersCorrectMatcherType()
	{
		//Given/When
		Double x = fflib_Match.doubleLessThan(0);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalLessThan);
	}

	@isTest
	private static void doubleMoreThanRegistersCorrectMatcherType()
	{
		//Given/When
		Double x = fflib_Match.doubleMoreThan(0);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalMoreThan);
	}

	@isTest
	private static void fieldSetEquivalentWithNullFieldSetThrowsException()
	{
		try
		{
			fflib_Match.fieldSetEquivalentTo(null);
			System.assert(false, 'ExpectedException');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			System.assertEquals('Arg cannot be null: null', e.getMessage());
		}
	}

	@isTest
	private static void fieldSetEquivalentToRegistersCorrectMatcherType()
	{
		Schema.FieldSet anyFieldSet = fflib_ApexMocksUtilsTest.findAnyFieldSet();
		if (anyFieldSet == null)
		{
			return;
		}

		//Given/When
		Schema.FieldSet x = fflib_Match.fieldSetEquivalentTo(anyFieldSet);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.FieldSetEquivalentTo);
	}

	@isTest
	private static void integerBetweenRegistersCorrectMatcherType()
	{
		//Given/When
		Integer x = fflib_Match.integerBetween(0, 10);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalBetween);
	}

	@isTest
	private static void integerLessThanRegistersCorrectMatcherType()
	{
		//Given/When
		Integer x = fflib_Match.integerLessThan(0);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalLessThan);
	}

	@isTest
	private static void integerMoreThanRegistersCorrectMatcherType()
	{
		//Given/When
		Integer x = fflib_Match.integerMoreThan(0);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalMoreThan);
	}

	@isTest
	private static void isNotNullRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.isNotNull();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.IsNotNull);
	}

	@isTest
	private static void isNullRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.isNull();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.IsNull);
	}

	@isTest
	private static void listContainsRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.listContains('fred');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.ListContains);
	}

	@isTest
	private static void listIsEmptyRegistersCorrectMatcherType()
	{
		//Given/When
		Object x = fflib_Match.listIsEmpty();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.ListIsEmpty);
	}

	@isTest
	private static void longBetweenRegistersCorrectMatcherType()
	{
		//Given/When
		Long x = fflib_Match.longBetween(0, 10);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalBetween);
	}

	@isTest
	private static void longLessThanRegistersCorrectMatcherType()
	{
		//Given/When
		Long x = fflib_Match.longLessThan(0);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalLessThan);
	}

	@isTest
	private static void longMoreThanRegistersCorrectMatcherType()
	{
		//Given/When
		Long x = fflib_Match.longMoreThan(0);
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.DecimalMoreThan);
	}

	@isTest
	private static void sObjectOfTypeRegistersCorrectMatcherType()
	{
		//Given
		Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
		if (ot == null)
		{
			return;
		}

		//When
		SObject x = fflib_Match.sObjectOfType(ot);

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.SObjectOfType);
	}

	@isTest
	private static void sObjectWithRegistersCorrectMatcherType()
	{
		//Given
		Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
		if (ot == null)
		{
			return;
		}

		Schema.SObjectField f = ot.getDescribe().fields.getMap().get('Id');

		//When
		SObject x = fflib_Match.sObjectWith(new Map<Schema.SObjectField, Object>{ f=>null });

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.SObjectWith);
	}

    @isTest
	private static void sObjectsWithRegistersCorrectMatcherType()
	{
		//Given
		Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
		if (ot == null)
		{
			return;
		}

		Schema.SObjectField f = ot.getDescribe().fields.getMap().get('Id');

		//When
		SObject[] x = fflib_Match.sObjectsWith(new list<Map<Schema.SObjectField, Object>>{ 
            new map<Schema.SObjectField,Object> {f=>null}
        	});

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.SObjectsWith);
	}

    @isTest
	private static void sObjectsWithMatchInOrderRegistersCorrectMatcherType()
	{
		//Given
		Schema.SObjectType ot = Schema.getGlobalDescribe().get('Account');
		if (ot == null)
		{
			return;
		}

		Schema.SObjectField f = ot.getDescribe().fields.getMap().get('Id');

		//When
		SObject[] x = fflib_Match.sObjectsWith(new list<Map<Schema.SObjectField, Object>>{ 
            new map<Schema.SObjectField,Object> {f=>null}
        	}, false);

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.SObjectsWith,registeredMatchers);
	}
    
	@isTest
	private static void sObjectWithIdRegistersCorrectMatcherType()
	{
		//Given/When
		SObject x = fflib_Match.sObjectWithId('001000000000001AAA');

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.SObjectWithId);
	}

	@isTest
	private static void sObjectWithNameRegistersCorrectMatcherType()
	{
		//Given/When
		SObject x = fflib_Match.sObjectWithName('hello');

		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.SObjectWithName);
	}

	@isTest
	private static void stringContainsRegistersCorrectMatcherType()
	{
		//Given/When
		String x = fflib_Match.stringContains('hello');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.StringContains);
	}

	@isTest
	private static void stringEndsWithRegistersCorrectMatcherType()
	{
		//Given/When
		String x = fflib_Match.stringEndsWith('hello');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.StringEndsWith);
	}

	@isTest
	private static void stringIsBlankRegistersCorrectMatcherType()
	{
		//Given/When
		String x = fflib_Match.stringIsBlank();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.StringIsBlank);
	}

	@isTest
	private static void stringIsNotBlankRegistersCorrectMatcherType()
	{
		//Given/When
		String x = fflib_Match.stringIsNotBlank();
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.StringIsNotBlank);
	}

	@isTest
	private static void stringMatchesRegistersCorrectMatcherType()
	{
		//Given/When
		String x = fflib_Match.stringMatches('[a-z]*');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.StringMatches);
	}

	@isTest
	private static void stringStartsWithRegistersCorrectMatcherType()
	{
		//Given/When
		String x = fflib_Match.stringStartsWith('hello');
		
		//Then
		List<fflib_IMatcher> registeredMatchers = fflib_Match.getAndClearMatchers(1);
		System.assertNotEquals(null, registeredMatchers);
		System.assertEquals(1, registeredMatchers.size());
		System.assert(registeredMatchers[0] instanceof fflib_MatcherDefinitions.StringStartsWith);
	}

	private class AlwaysMatch implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return true;
		}
	}
	
	private class NeverMatch implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return false;
		}
	}
}