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

	private class MyException extends Exception
	{
	}
}