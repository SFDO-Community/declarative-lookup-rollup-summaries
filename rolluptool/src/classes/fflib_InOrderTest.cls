/*
 Copyright (c) 2014-2017 FinancialForce.com, inc.  All rights reserved.
 */

@isTest
private class fflib_InOrderTest
{
	private static fflib_ApexMocks MY_MOCKS = new fflib_ApexMocks();

	@isTest
	static void thatVerifyInOrderAllTheMethodsCalled()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('1-2');
		firstMock.add('1-3');
		firstMock.add('1-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-2');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-3');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-4');

		assertVerifyInOrderExceptionForAddMethod('1-2', inOrder1, firstMock,
			'It should fail because 1-2 is in the wrong order', 1, 0 );
	}

	@isTest
	static void thatVerifyInOrderDifferentMethodsCalledWithSameArguments()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.addMore('1-1');
		firstMock.add('1-2');
		firstMock.addMore('1-2');
		firstMock.add('1-3');
		firstMock.addMore('1-3');
		firstMock.add('1-4');
		firstMock.addMore('1-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).addMore('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).addMore('1-3');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-4');
	}

	@isTest
	static void thatVerifyInOrderDifferentMethodsCalledWithSameArgumentsOrderFail()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.addMore('1-1');
		firstMock.add('1-2');
		firstMock.addMore('1-2');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).addMore('1-1');

		assertVerifyInOrderExceptionForAddMethod('1-1', inOrder1, firstMock,
			'It should fail because 1-1 is called before the addMore(1-1)', 1, 0 );
	}

	@isTest
	static void thatVerifyInOrderDifferentMethodsCalledWithSameArgumentsDoubleCallFail()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.addMore('1-1');
		firstMock.add('1-2');
		firstMock.addMore('1-2');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).addMore('1-1');

		assertVerifyInOrderExceptionForAddMoreMethod('1-1', inOrder1, firstMock,
			'It should fail because addMore(1-1) is called only Once', 1, 0 );
	}

	@isTest
	static void thatVerifyInOrderCallMethodWithMatches()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-0');
		firstMock.add('1-11');
		firstMock.add('1-12');
		firstMock.add('1-3');
		firstMock.add('1-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(2))).add(fflib_Match.stringStartsWith('1-1'));
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-4');
	}

	@isTest
	static void thatVerifyInOrderCallMethodWithMatchesFailsIfVerifyACallAlreadyInTheMatcher()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-0');
		firstMock.add('1-11');
		firstMock.add('1-12');
		firstMock.add('1-3');
		firstMock.add('1-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(2))).add(fflib_Match.stringStartsWith('1-1'));
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-4');

		assertVerifyInOrderExceptionForAddMethod('1-11', inOrder1, firstMock,
			'It should fail because addMore(1-11) has been already verified using the matchers', 1, 0 );
	}

	@isTest
	static void thatVerifyInOrderCallMethodWithMultipleMatches()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When

		firstMock.add('1-0');
		firstMock.add('1-1');
		firstMock.add('1-3');
		firstMock.add('1-4');


		firstMock.add('2-0');
		firstMock.add('2-1');
		firstMock.add('2-3');
		firstMock.add('2-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(4))).add(fflib_Match.stringStartsWith('1-'));
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(4))).add(fflib_Match.stringStartsWith('2-'));
	}

	@isTest
	static void thatVerifyInOrderCallMethodWithMultipleMatchesMixed()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-2');
		firstMock.add('2-2');
		firstMock.add('1-3');
		firstMock.add('2-3');
		firstMock.add('1-4');
		firstMock.add('2-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(4))).add(fflib_Match.stringStartsWith('1-'));
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add(fflib_Match.stringStartsWith('2-'));
	}

	@isTest
	static void thatVerifyInOrderCallMethodWithMultipleMatchesMixedFailWhenMatcherHaveAlreadyVerifiedMethod()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-2');
		firstMock.add('2-2');
		firstMock.add('1-3');
		firstMock.add('2-3');
		firstMock.add('1-4');
		firstMock.add('2-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(4))).add(fflib_Match.stringStartsWith('1-'));

		assertVerifyInOrderExceptionForAddMethod('1-11', inOrder1, firstMock,
			'It should fail because only one call for the 2- is available to verify', 4, 0 );
	}

	@isTest
	static void thatVerifyInOrderCanSkipMethodsCalledUntilFindTheOneThatNeedsVerify()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('1-2');
		firstMock.add('1-3');
		firstMock.add('1-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-4');

		assertVerifyInOrderExceptionForAddMethod('1-2', inOrder1, firstMock,
			'It should fail because is out of order', 1, 0 );
	}

	@isTest
	static void thatVerifyInOrderCanHandleMultipleMethodsCalls()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('1-2');
		firstMock.add('1-2');
		firstMock.add('1-2');
		firstMock.add('1-3');
		firstMock.add('1-4');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(3))).add('1-2');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-4');
	}

	@isTest
	static void thatVerifyInOrderCanHandleMultipleMethodsCallsAndNotFailsIfVerifyCountIsGreaterThenExpected()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('1-2');
		firstMock.add('1-2');
		firstMock.add('1-2');
		firstMock.add('1-3');
		firstMock.add('1-4');

		// Then

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(2))).add('1-2');
	}

	@isTest
	static void thatVerifyInOrderCanHandleMultipleMethodsCallsButFailsIfVerifyCountIsLessThenExpected()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('1-2');
		firstMock.add('1-2');
		firstMock.add('1-2');
		firstMock.add('1-3');
		firstMock.add('1-4');

		// Then

		assertVerifyInOrderExceptionForAddMethod('1-2', inOrder1, firstMock,
			'It should fail because is actually called only 3 times', 4, 3 );
	}

	@isTest
	static void thatVerifyInOrderCanHandleMultipleMocks()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_MyList secondMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_MyList thirdMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);

		fflib_InOrder inOrder = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock, secondMock });

		// When
		firstMock.add('1-1');
		secondMock.add('2-1');
		thirdMock.add('3-1');

		firstMock.add('1-2');
		secondMock.add('2-2');
		thirdMock.add('3-2');

		firstMock.add('1-1');
		firstMock.add('1-3');
		secondMock.add('2-3');
		thirdMock.add('3-3');

		// Then
		((fflib_MyList.IList)inOrder.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder.verify(secondMock, MY_MOCKS.calls(1))).add('2-1');
		((fflib_MyList.IList)inOrder.verify(firstMock, MY_MOCKS.calls(1))).add('1-2');
		((fflib_MyList.IList)inOrder.verify(secondMock, MY_MOCKS.calls(1))).add('2-2');
		((fflib_MyList.IList)inOrder.verify(firstMock, MY_MOCKS.calls(1))).add('1-3');
		((fflib_MyList.IList)inOrder.verify(secondMock, MY_MOCKS.calls(1))).add('2-3');

		((fflib_MyList.IList)MY_MOCKS.verify(thirdMock, MY_MOCKS.times(3))).add(fflib_Match.stringStartsWith('3-'));
	}

	@isTest
	static void thatVerifyInOrderCanHandleMixedInOrderInstance()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_MyList secondMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_MyList thirdMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);

		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });
		fflib_InOrder inOrder2 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock, secondMock });

		// When
		firstMock.add('1-1');
		secondMock.add('2-1');
		thirdMock.add('3-1');

		firstMock.add('1-2');
		secondMock.add('2-2');
		thirdMock.add('3-2');

		firstMock.add('1-1');
		firstMock.add('1-3');
		secondMock.add('2-3');
		thirdMock.add('3-3');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(2))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-3');


		((fflib_MyList.IList)inOrder2.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');

		((fflib_MyList.IList)inOrder2.verify(firstMock, MY_MOCKS.calls(1))).add('1-2');
		((fflib_MyList.IList)inOrder2.verify(secondMock, MY_MOCKS.calls(1))).add('2-2');
		((fflib_MyList.IList)inOrder2.verify(firstMock, MY_MOCKS.calls(1))).add('1-3');
		((fflib_MyList.IList)inOrder2.verify(secondMock, MY_MOCKS.calls(1))).add('2-3');

		((fflib_MyList.IList)MY_MOCKS.verify(thirdMock, MY_MOCKS.times(3))).add(fflib_Match.stringStartsWith('3-'));
	}

	@isTest
	static void thatVerifyInOrderThrownExceptionIfVerifyMockInstanceNotInTheSet()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_MyList secondMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);

		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		secondMock.add('2-1');

		// Then

		try
		{
			((fflib_MyList.IList)inOrder1.verify(secondMock, MY_MOCKS.calls(1))).add('2-1');
			System.assert(false, 'An exception was expected, because this verify is not in the list of the mocks to verify');
		}
		catch(fflib_ApexMocks.ApexMocksException mockexcep)
		{
			String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: ' + fflib_MyList.getStubClassName() + '.add(String).';
			System.assertEquals(expectedMessage, mockexcep.getMessage(),
				'an exception has been caught as expected, however the message is not as expected');
		}
	}

	@isTest
	static void thatVerifyInOrderThrownExceptionWithCustomMessage()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);

		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		String customErrorMesage = 'Some custom error message';

		// When
		firstMock.add('1-1');
		firstMock.add('1-2');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-2');
		// Then
		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.description(customErrorMesage))).add('1-1');
			System.assert(false, 'expected some exception ');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: ' + fflib_MyList.getStubClassName() + '.add(String). Some custom error message.';
			System.assertEquals(
				expectedMessage,
				e.getMessage(),
				'the verify throw an Exception, but the message is not as expected');
		}
	}

	@isTest
	static void thatVerifyAtMostThrowsExceptionBecauseNotImplemented()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atMost(3))).add('1-1');
			System.assert(false, 'an exception was expected because the method is not implemented for the InOrder class');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'The atMost method is not implemented for the fflib_InOrder class';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyTimesThrowsExceptionBecauseNotImplemented()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(3))).add('1-1');
			System.assert(false, 'an exception was expected because the method is not implemented for the InOrder class');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'The times method is not implemented for the fflib_InOrder class';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyAtLeastThrowsExceptionBecauseNotImplemented()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(3))).add('1-1');
			System.assert(false, 'an exception was expected because the method is not implemented for the InOrder class');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'The atLeast method is not implemented for the fflib_InOrder class';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyBetweenThrowsExceptionBecauseNotImplemented()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.between(3, 5))).add('1-1');
			System.assert(false, 'an exception was expected because the method is not implemented for the InOrder class');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'The between method is not implemented for the fflib_InOrder class';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyNever()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.never())).add('3-1');
	}

	@isTest
	static void thatVerifyNeverWithMatchers()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.never())).add(fflib_Match.stringStartsWith('3-'));
	}

	@isTest
	static void thatVerifyNeverFailsWhenCalled()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.never())).add('1-1');
			System.assert(false, 'expected some exception because the method has been called');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			String expectedMessage = 'In Order: Expected : 0, Actual: 4 -- Wanted but not invoked: ' + fflib_MyList.getStubClassName() + '.add(String).';

			System.assertEquals(expectedMessage, e.getMessage(),
				'the verify throw an Exception, but the message is not as expected');
		}
	}

	@isTest
	static void thatVerifyNeverFailsWhenCalledWithMatchers()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.never())).add(fflib_Match.stringStartsWith('1-'));
			System.assert(false, 'expected some exception because the method has been called');
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			String expectedMessage = 'In Order: Expected : 0, Actual: 4 -- Wanted but not invoked: ' + fflib_MyList.getStubClassName() + '.add(String).';

			System.assertEquals(expectedMessage, e.getMessage(),
				'the verify throw an Exception, but the message is not as expected');
		}
	}

	@isTest
	static void thatVerifyAtLeastOnceThrowsExceptionBecauseNotImplemented()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');

		// Then
		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce())).add('1-1');
			System.assert(false, 'an exception was expected because the method is not implemented for the InOrder class');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'The atLeastOnce method is not implemented for the fflib_InOrder class';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyThrowsExceptionWhenCallsIsInvochedFromStandardMock()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');

		// Then
		try
		{
			((fflib_MyList.IList) MY_MOCKS.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
			System.assert(false, 'an exception was expected because the method is only implemented for the InOrder class');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'The calls() method is available only in the InOrder Verification.';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyNoMoreInteractionsFails()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1', '1-1', '1-1', '1-1');
		firstMock.addMore('2-1');
		firstMock.add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1', '1-1', '1-1', '1-1');

		// Then
		try
		{
			inOrder1.verifyNoMoreInteractions();
			System.assert(false, 'an exception was expected because there are other interactions');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'No more Interactions were expected after the ' + fflib_MyList.getStubClassName() + '.add(String, String, String, String) method.';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyNoMoreInteractionsFailsWhenOnLyOneMethodLeft()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1', '1-1', '1-1', '1-1');
		firstMock.addMore('2-1');
		firstMock.add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).addMore('2-1');

		// Then
		try
		{
			inOrder1.verifyNoMoreInteractions();
			System.assert(false, 'an exception was expected because there are other interactions');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'No more Interactions were expected after the ' + fflib_MyList.getStubClassName() + '.addMore(String) method.';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyNoMoreInteractionsPass()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_MyList secondMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });
		fflib_InOrder inOrder2 = new fflib_InOrder(MY_MOCKS, new List<Object>{ secondMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		secondMock.add('1-1');
		secondMock.add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');

		inOrder1.verifyNoMoreInteractions();

		((fflib_MyList.IList)inOrder2.verify(secondMock, MY_MOCKS.calls(2))).add('1-1');

		inOrder2.verifyNoMoreInteractions();
	}

	@isTest
	static void thatVerifyNoMoreInteractionsFailsWhenNoInteracionOccurs()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');

		// Then
		try
		{
			inOrder1.verifyNoMoreInteractions();
			System.assert(false, 'an exception was expected because there are other interactions');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'No Interactions expected on this InOrder Mock instance!';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyNoInteractionsFails()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');

		// Then
		try
		{
			inOrder1.verifyNoInteractions();
			System.assert(false, 'an exception was expected because there are other interactions');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'No Interactions expected on this InOrder Mock instance!';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyNoInteractionsPass()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_MyList secondMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });


		// When
		secondMock.add('1-2');
		//Then
		inOrder1.verifyNoInteractions();
	}

	@isTest
	static void thatStrictVerificationCanBePerformed()
	{
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('4-1');
		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('4-1');
	}

	@isTest
	static void thatMixedVerificationDoNotInterfierWithOtherImplementationChecking()
	{
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('4-1');
		// Then
		((fflib_MyList.IList)MY_MOCKS.verify(firstMock, MY_MOCKS.times(2))).add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('4-1');

		((fflib_MyList.IList)MY_MOCKS.verify(firstMock, MY_MOCKS.times(2))).add('1-1');
	}


	private static void assertVerifyInOrderExceptionForAddMoreMethod(
		String argument,
		fflib_InOrder inOrderInstance,
		fflib_MyList.IList mockToVerify,
		String expectedFailingReasson,
		Integer expectedCount,
		Integer actualCounts
		)
	{
		try
		{
			((fflib_MyList.IList)inOrderInstance.verify(mockToVerify, MY_MOCKS.calls(1))).addMore(argument);
			System.assert(false, 'expected some exception ' + expectedFailingReasson);
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{
			String message = 'In Order: Expected : {0}, Actual: {1} -- Wanted but not invoked: {2}.addMore(String).';

			String expectedMessage = String.format(message, new List<String>{
					'' + expectedCount,
					'' + actualCounts,
					fflib_MyList.getStubClassName()
				});

			System.assertEquals(expectedMessage, e.getMessage(),
				'the verify throw an Exception, but the message is not as expected');
		}
	}


	private static void assertVerifyInOrderExceptionForAddMethod(
		String argument,
		fflib_InOrder inOrderInstance,
		fflib_MyList.IList mockToVerify,
		String expectedFailingReasson,
		Integer expectedCount,
		Integer actualCounts
		)
	{
		try
		{
			((fflib_MyList.IList)inOrderInstance.verify(mockToVerify, MY_MOCKS.calls(expectedCount))).add(argument);
			System.assert(false, 'expected some exception ' + expectedFailingReasson);
		}
		catch (fflib_ApexMocks.ApexMocksException e)
		{

			String message = 'In Order: Expected : {0}, Actual: {1} -- Wanted but not invoked: {2}.add(String).';

			String expectedMessage = String.format(message, new List<String>{
					'' + expectedCount,
					'' + actualCounts,
					fflib_MyList.getStubClassName()
				});

			System.assertEquals(expectedMessage, e.getMessage(),
				'the verify throw an Exception, but the message is not as expected');
		}
	}
}