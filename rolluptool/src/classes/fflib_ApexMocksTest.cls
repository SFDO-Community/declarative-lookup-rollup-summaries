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
private class fflib_ApexMocksTest
{
	@isTest
	static void whenStubMultipleCallsWithMatchersShouldReturnExpectedValues()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.get2(fflib_Match.anyInteger(), fflib_Match.anyString())).thenReturn('any');
		mocks.when(mockList.get2(fflib_Match.anyInteger(), fflib_Match.stringContains('Hello'))).thenReturn('hello');
		mocks.stopStubbing();

		// When
		String actualValue = mockList.get2(0, 'Hi hi Hello Hi hi');

		// Then
		System.assertEquals('hello', actualValue);
	}
	
	@isTest
	static void whenVerifyMultipleCallsWithMatchersShouldReturnCorrectMethodCallCounts()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((fflib_MyList.IList) mocks.verify(mockList, 2)).add(fflib_Match.anyString());
		((fflib_MyList.IList) mocks.verify(mockList)).add('fred');
		((fflib_MyList.IList) mocks.verify(mockList)).add(fflib_Match.stringContains('fred'));
	}
	
	@isTest
	static void whenStubExceptionWithMatchersShouldThrowException()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		((fflib_MyList.IList) mocks.doThrowWhen(new MyException('Matcher Exception'),  mockList)).add(fflib_Match.stringContains('Hello'));
		mocks.stopStubbing();

		// When
		mockList.add('Hi');
		
		try
		{
			mockList.add('Hi Hello Hi');
			System.assert(false, 'Expected exception');
		}
		catch (MyException e)
		{
			//Then
			System.assertEquals('Matcher Exception', e.getMessage());
		}
	}
	
	@isTest
	static void whenVerifyWithCombinedMatchersShouldReturnCorrectMethodCallCounts()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((fflib_MyList.IList) mocks.verify(mockList, 0)).add(
			(String)fflib_Match.allOf(fflib_Match.eq('bob'), fflib_Match.stringContains('re'))
		);
		
		((fflib_MyList.IList) mocks.verify(mockList)).add(
			(String)fflib_Match.allOf(fflib_Match.eq('fred'), fflib_Match.stringContains('re'))
		);
		
		((fflib_MyList.IList) mocks.verify(mockList, 2)).add(
			(String)fflib_Match.anyOf(fflib_Match.eq('bob'), fflib_Match.eq('fred'))
		);
		
		((fflib_MyList.IList) mocks.verify(mockList, 1)).add(
			(String)fflib_Match.anyOf(fflib_Match.eq('bob'), fflib_Match.eq('jack'))
		);
		
		((fflib_MyList.IList) mocks.verify(mockList, 2)).add(
			(String)fflib_Match.noneOf(fflib_Match.eq('jack'), fflib_Match.eq('tim'))
		);
		
		((fflib_MyList.IList) mocks.verify(mockList, 2)).add(
			(String)fflib_Match.noneOf(
				fflib_Match.anyOf(fflib_Match.eq('jack'), fflib_Match.eq('jill')),
				fflib_Match.allOf(fflib_Match.eq('tim'), fflib_Match.stringContains('i'))
			)
		);
		
		((fflib_MyList.IList) mocks.verify(mockList, 2)).add(
			(String)fflib_Match.isNot(fflib_Match.eq('jack'))
		);
	}

	@isTest
	static void whenStubCustomMatchersCanBeUsed()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.get((Integer)fflib_Match.matches(new isOdd()))).thenReturn('Odd');
		mocks.when(mockList.get((Integer)fflib_Match.matches(new isEven()))).thenReturn('Even');
		mocks.stopStubbing();

		// When
		String s1 = mockList.get(1);
		String s2 = mockList.get(2);
		String s3 = mockList.get(3);
		String s4 = mockList.get(4);
		String s5 = mockList.get(5);

		// Then
		System.assertEquals('Odd', s1);
		System.assertEquals('Even', s2);
		System.assertEquals('Odd', s3);
		System.assertEquals('Even', s4);
		System.assertEquals('Odd', s5);
	}

	@isTest
	static void whenVerifyCustomMatchersCanBeUsed()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.get(1);
		mockList.get(2);
		mockList.get(3);
		mockList.get(4);
		mockList.get(5);

		// Then
		((fflib_MyList.IList) mocks.verify(mockList, 3)).get((Integer)fflib_Match.matches(new isOdd()));
		((fflib_MyList.IList) mocks.verify(mockList, 2)).get((Integer)fflib_Match.matches(new isEven()));
	}

	@isTest
	static void whenStubWithMatcherAndNonMatcherArgumentsShouldThrowException()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		String expectedError = 'The number of matchers defined (1).'
				+ ' does not match the number expected (2)\n'
				+ 'If you are using matchers all arguments must be passed in as matchers.\n'
				+ 'For example myList.add(fflib_Match.anyInteger(), \'String\') should be defined as myList.add(fflib_Match.anyInteger(), fflib_Match.eq(\'String\')).';

		// Then
		try
		{
			mocks.startStubbing();
			mocks.when(mockList.get2(fflib_Match.anyInteger(), 'String literal')).thenReturn('fail');
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			System.assertEquals(expectedError, e.getMessage());
		}
	}

	@isTest
	static void whenVerifyWithMatcherAndNonMatcherArgumentsShouldThrowException()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		String expectedError = 'The number of matchers defined (1).'
				+ ' does not match the number expected (2)\n'
				+ 'If you are using matchers all arguments must be passed in as matchers.\n'
				+ 'For example myList.add(fflib_Match.anyInteger(), \'String\') should be defined as myList.add(fflib_Match.anyInteger(), fflib_Match.eq(\'String\')).';

		mockList.get2(1, 'String literal');

		// Then
		try
		{
			((fflib_MyList.IList) mocks.verify(mockList)).get2(fflib_Match.anyInteger(), 'String literal');
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			System.assertEquals(expectedError, e.getMessage());
		}
	}

	@isTest
	static void whenStubSameMethodWithMatchersAndNonMatchersShouldStubInOrder()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		
		mocks.when(mockList.get2(1, 'Non-matcher first')).thenReturn('Bad'); //Set the return value using the non-matcher arguments
		mocks.when(mockList.get2(fflib_Match.eqInteger(1), fflib_Match.stringContains('Non-matcher first'))).thenReturn('Good'); //Override the return value using matcher arguments

		mocks.when(mockList.get2(fflib_Match.eqInteger(1), fflib_Match.stringContains('Matcher first'))).thenReturn('Bad'); //Set the return value using the matcher arguments
		mocks.when(mockList.get2(1, 'Matcher first')).thenReturn('Good'); //Override the return value using non-matcher arguments
		
		mocks.stopStubbing();

		// When/Thens
		System.assertEquals('Good', mockList.get2(1, 'Non-matcher first'));
		System.assertEquals('Good', mockList.get2(1, 'Matcher first'));
	}

	@isTest
	static void whenStubExceptionSameMethodWithMatchersAndNonMatchersShouldStubInOrder()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		
		((fflib_MyList.IList)mocks.doThrowWhen(new fflib_ApexMocks.ApexMocksException('Bad'), mockList)).add('Non-matcher first'); //Set the exception value using the non-matcher arguments
		((fflib_MyList.IList)mocks.doThrowWhen(new fflib_ApexMocks.ApexMocksException('Good'), mockList)).add(fflib_Match.stringContains('Non-matcher first')); //Override the exception value using matcher arguments

		((fflib_MyList.IList)mocks.doThrowWhen(new fflib_ApexMocks.ApexMocksException('Bad'), mockList)).add(fflib_Match.stringContains('Matcher first')); //Set the exception value using the matcher arguments
		((fflib_MyList.IList)mocks.doThrowWhen(new fflib_ApexMocks.ApexMocksException('Good'), mockList)).add('Matcher first'); //Override the exception value using non-matcher arguments
		
		mocks.stopStubbing();

		// When/Thens
		try
		{
			mockList.add('Non-matcher first');
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			System.assertEquals('Good', e.getMessage());
		}

		try
		{
			mockList.add('Matcher first');
			System.assert(false, 'Expected exception');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			System.assertEquals('Good', e.getMessage());
		}
	}
	
	@isTest
	static void whenStubSingleCallWithSingleArgumentShouldReturnStubbedValue()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.get(0)).thenReturn('bob');
		mocks.stopStubbing();

		// When
		String actualValue = mockList.get(0);

		// Then
		System.assertEquals('bob', actualValue);
	}

	@isTest
	static void whenStubSingleCallWithNullReturnValueItShouldReturnNull()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.get(0)).thenReturn(null);
		mocks.stopStubbing();

		// When
		String actualValue = mockList.get(0);

		// Then
		System.assertEquals(null, actualValue);
	}

	@isTest
	static void whenStubMultipleCallsWithSingleArgumentShouldReturnStubbedValues()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.get(0)).thenReturn('bob');
		mocks.when(mockList.get(1)).thenReturn('fred');
		mocks.stopStubbing();

		// When
		String actualValueArg0 = mockList.get(0);
		String actualValueArg1 = mockList.get(1);
		String actualValueArg2 = mockList.get(2);

		// Then
		System.assertEquals('bob', actualValueArg0);
		System.assertEquals('fred', actualValueArg1);
		System.assertEquals(null, actualValueArg2);
	}

	@isTest
	static void whenStubSameCallWithDifferentArgumentValueShouldReturnLastStubbedValue()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.get(0)).thenReturn('bob1');
		mocks.when(mockList.get(0)).thenReturn('bob2');
		mocks.stopStubbing();

		// When
		String actualValue = mockList.get(0);

		// Then
		System.assertEquals('bob2', actualValue);
	}

	@isTest
	static void whenStubCallWithNoArgumentsShouldReturnStubbedValue()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.isEmpty()).thenReturn(false);
		mocks.stopStubbing();

		// When
		Boolean actualValue = mockList.isEmpty();

		// Then
		System.assertEquals(false, actualValue);
	}

	@isTest
	static void verifySingleMethodCallWithNoArguments()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.isEmpty();

		// Then
		((fflib_MyList.IList) mocks.verify(mockList)).isEmpty();
	}

	@isTest
	static void verifySingleMethodCallWithSingleArgument()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.add('bob');

		// Then
		((fflib_MyList.IList) mocks.verify(mockList)).add('bob');
	}

	@isTest
	static void verifyMultipleMethodCallsWithSameSingleArgument()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.add('bob');
		mockList.add('bob');

		// Then
		((fflib_MyList.IList) mocks.verify(mockList, 2)).add('bob');
	}

	@isTest
	static void verifyMultipleMethodCallsWithDifferentSingleArgument()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.add('bob');
		mockList.add('fred');

		// Then
		((fflib_MyList.IList) mocks.verify(mockList)).add('bob');
		((fflib_MyList.IList) mocks.verify(mockList)).add('fred');
	}

	@isTest
	static void verifyMethodCallsWithSameNameButDifferentArgumentTypes()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.add('bob');
		mockList.add(new String[] {'bob'});
		mockList.add((String)null);
		mockList.add((String[])null);

		// Then
		((fflib_MyList.IList) mocks.verify(mockList)).add('bob');
		((fflib_MyList.IList) mocks.verify(mockList)).add(new String[] {'bob'});
		((fflib_MyList.IList) mocks.verify(mockList)).add((String)null);
		((fflib_MyList.IList) mocks.verify(mockList)).add((String[])null);
	}

	@isTest
	static void verifyMethodNotCalled()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.get(0);

		// Then
		((fflib_MyList.IList) mocks.verify(mockList, fflib_ApexMocks.NEVER)).add('bob');
		((fflib_MyList.IList) mocks.verify(mockList)).get(0);
	}

	@isTest
	static void stubAndVerifyMethodCallsWithNoArguments()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.isEmpty()).thenReturn(false);
		mocks.stopStubbing();

		mockList.clear();

		// When
		Boolean actualValue = mockList.isEmpty();

		// Then
		System.assertEquals(false, actualValue);
		((fflib_MyList.IList) mocks.verify(mockList)).clear();
	}

	@isTest
	static void whenStubExceptionTheExceptionShouldBeThrown()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.get(0)).thenThrow(new MyException('Stubbed exception.'));
		mocks.stopStubbing();

		// When
		try
		{
			mockList.get(0);
			System.assert(false, 'Stubbed exception should have been thrown.');
		}
		catch(Exception e)
		{
			// Then
			System.assert(e instanceof MyException);
			System.assertEquals('Stubbed exception.', e.getMessage());
		}
	}

	@isTest
	static void whenStubVoidMethodWithExceptionThenExceptionShouldBeThrown()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		((fflib_MyList.IList) mocks.doThrowWhen(new MyException('Stubbed exception.'), mockList)).clear();
		mocks.stopStubbing();

		// When
		try
		{
			mockList.clear();
			System.assert(false, 'Stubbed exception should have been thrown.');
		}
		catch(Exception e)
		{
			// Then
			System.assert(e instanceof MyException);
			System.assertEquals('Stubbed exception.', e.getMessage());
		}
	}

	@isTest
	static void whenStubMultipleVoidMethodsWithExceptionsThenExceptionsShouldBeThrown()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		((fflib_MyList.IList) mocks.doThrowWhen(new MyException('clear stubbed exception.'), mockList)).clear();
		((fflib_MyList.IList) mocks.doThrowWhen(new MyException('add stubbed exception.'), mockList)).add('bob');
		mocks.stopStubbing();

		// When
		try
		{
			mockList.clear();
			System.assert(false, 'Stubbed exception should have been thrown.');
		}
		catch(Exception e)
		{
			// Then
			System.assert(e instanceof MyException);
			System.assertEquals('clear stubbed exception.', e.getMessage());
		}

		// When
		try
		{
			mockList.add('bob');
			System.assert(false, 'Stubbed exception should have been thrown.');
		}
		catch(Exception e)
		{
			// Then
			System.assert(e instanceof MyException);
			System.assertEquals('add stubbed exception.', e.getMessage());
		}
	}

	@isTest
	static void whenStubVoidMethodWithExceptionAndCallMethodTwiceThenExceptionShouldBeThrownTwice()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		((fflib_MyList.IList) mocks.doThrowWhen(new MyException('clear stubbed exception.'), mockList)).clear();
		mocks.stopStubbing();

		// When
		try
		{
			mockList.clear();
			System.assert(false, 'Stubbed exception should have been thrown.');
		}
		catch(Exception e)
		{
			// Then
			System.assert(e instanceof MyException);
			System.assertEquals('clear stubbed exception.', e.getMessage());
		}

		// When
		try
		{
			mockList.clear();
			System.assert(false, 'Stubbed exception should have been thrown.');
		}
		catch(Exception e)
		{
			// Then
			System.assert(e instanceof MyException);
			System.assertEquals('clear stubbed exception.', e.getMessage());
		}

		((fflib_MyList.IList)mocks.verify(mockList, 2)).clear();
	}

	@isTest
	static void verifyMethodCallWhenNoCallsBeenMadeForType()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// Then
		((fflib_MyList.IList) mocks.verify(mockList, fflib_ApexMocks.NEVER)).add('bob');
	}

	@isTest
	static void verifySingleMethodCallWithMultipleArguments()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.set(0, 'bob');

		// Then
		((fflib_MyList.IList) mocks.verify(mockList)).set(0, 'bob');
		((fflib_MyList.IList) mocks.verify(mockList, fflib_ApexMocks.NEVER)).set(0, 'fred');
	}

	@isTest
	static void whenStubMultipleCallsWithMultipleArgumentShouldReturnStubbedValues()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		mocks.startStubbing();
		mocks.when(mockList.get2(0, 'zero')).thenReturn('bob');
		mocks.when(mockList.get2(1, 'one')).thenReturn('fred');
		mocks.when(mockList.get2(0, 'two')).thenReturn('bob');
		mocks.when(mockList.get2(1, 'three')).thenReturn('bub');
		mocks.stopStubbing();

		// When
		String actualValueArg0 = mockList.get2(0, 'zero');
		String actualValueArg1 = mockList.get2(1, 'one');
		String actualValueArg2 = mockList.get2(0, 'two');
		String actualValueArg3 = mockList.get2(1, 'three');
		String actualValueArg4 = mockList.get2(0, 'three');

		// Then
		System.assertEquals('bob', actualValueArg0);
		System.assertEquals('fred', actualValueArg1);
		System.assertEquals('bob', actualValueArg2);
		System.assertEquals('bub', actualValueArg3);
		System.assertEquals(null, actualValueArg4);
	}

	@isTest
	static void whenStubNullConcreteArgValueCorrectValueIsReturned()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		String expected = 'hello';

		mocks.startStubbing();
		mocks.when(mockList.get(null)).thenReturn(expected);
		mocks.stopStubbing();

		// When
		String actual = mockList.get(null);

		// Then
		System.assertEquals(expected, actual);
	}

	@isTest
	static void whenSetDoThrowWhenExceptionValueIsSet()
	{
		//Given
		MyException e = new MyException('Test');
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		
		//When
		mocks.DoThrowWhenException = e;

		//Then
		System.assert(e === mocks.DoThrowWhenException);
	}

	@isTest
	static void whenVerifyMethodNeverCalledMatchersAreReset()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

		// When
		mockList.add('bob');
		
		// Then
		((fflib_MyList.IList) mocks.verify(mockList, fflib_ApexMocks.NEVER)).get(fflib_Match.anyInteger());
		((fflib_MyList.IList) mocks.verify(mockList)).add(fflib_Match.anyString());
	}

	private class MyException extends Exception
	{
	}

	private class isOdd implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg instanceof Integer ? Math.mod((Integer)arg, 2) == 1: false;
		}
	}

	private class isEven implements fflib_IMatcher
	{
		public Boolean matches(Object arg)
		{
			return arg instanceof Integer ? Math.mod((Integer)arg, 2) == 0: false;
		}
	}
}