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

	@isTest
	static void thatVerifyAtLeastPassWithSameCallsOfAssertion()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		firstMock.add('2-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1'); //all consumed until there by -> verify(firstMock, MY_MOCKS.atLeast(3))).add('1-1');
		firstMock.add('2-1'); //finally consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(3))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
	}

	@isTest
	static void thatVerifyAtLeastPassWithMoreCallsThenAsserted()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		firstMock.add('2-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1'); //it verifies until here, but
		firstMock.add('1-1'); //this is consumed as well
		firstMock.add('2-1'); //finally consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(2))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
	}

	@isTest
	static void thatVerifyAtLeastThrowsErrorIfCalledLessTimes()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		firstMock.add('2-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1'); //there are then only 3 calls available, the assert 4 would fail
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(4))).add('1-1');
			System.assert(false, 'an exception was expected because the atLeast is asserting for 4 calls when instead there are only 3 not consumed calls');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 4, Actual: 3 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyAtLeastConsumeAllTheInstances()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		firstMock.add('2-1'); //consumed by -> verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1'); // the verify atLeast(2) it verifies until here, but it keep going through the instances
		firstMock.add('1-1');
		firstMock.add('2-1'); //so this would fail because have to first consume all the instances of the ('1-1')
		firstMock.add('1-1');
		firstMock.add('1-1');


		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(2))).add('1-1');

		// Then
		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
			System.assert(false, 'an exception was expected because the atLeast have consumed all the interactions of 1-1');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyAtLeastConsumeAllTheInstancesForOnlyTheMethodVerified()
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
		firstMock.add('2-1'); // verify(firstMock, MY_MOCKS.atLeast(2))).add('2-1'); consume until here
		firstMock.add('1-1');
		firstMock.add('1-1'); //those are then free for the second atLeast assertion

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(2))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(2))).add('1-1');
	}

	@isTest
	static void thatVerifyAtLeastOnce()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce())).add('1-1');
	}

	@isTest
	static void thatVerifyAtLeastOnceConsumesInstancesUntilLastMethodVerified()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1'); // consumed until there by -> verify(firstMock, MY_MOCKS.atLeastOnce())).add('1-1');
		firstMock.add('2-1'); // free for another assertion

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce())).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce())).add('2-1');
	}

	@isTest
	static void thatVerifyAtLeastOnceThrowsErrorIfCalledLessTimes()
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
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce())).add('1-3');
			System.assert(false, 'an exception was expected because the atLeastOnce is asserting for 1 calls when instead the method is not called at all with that argument');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyAtLeastOnceConsumesAllTheInstances()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		// When
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');
		firstMock.add('1-1'); //all the instance have been consumed

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeastOnce())).add('1-1');

		// Then
		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
			System.assert(false, 'an exception was expected because the atLeast have consumed all the interactions of 1-1');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyTimes()
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

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(3))).add('1-1');
	}

	@isTest
	static void thatVerifyTimesThrowsExceptionIfCalledMoreTimesThanExpected()
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
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(2))).add('1-1');
			System.assert(false, 'exception expected because the method is called more times than expected in the verification');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 2, Actual: 3 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyTimesThrowsExceptionIfCalledLessTimesThanExpected()
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
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(4))).add('1-1');
			System.assert(false, 'exception expected because the method is called more times than expected in the verification');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 4, Actual: 3 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatVerifyTimesPassWhenAnotherMethodIsCalledBetweenMethodsCalls()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(4))).add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('2-1');
	}

	@isTest
	static void thatVerifyTimesPassWhenAnotherMethodIsCalledBetweenMethodsCalls2()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(3))).add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('1-1');
	}

	@isTest
	static void thatVerifyTimesPassWhenAnotherMethodIsCalledBetweenMethodsCalls3()
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
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(3))).add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(2))).add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('1-1');
	}

	@isTest
	static void thatVerifyTimesPassWhenAnotherMethodIsCalledBetweenMethodsCalls4()
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
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('1-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(5))).add('1-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('1-1');
	}

	@isTest
	static void thatVerifyTimesThrowsExceptionWhenAnotherMethodIsCalledBetweenMethodsCalls()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(5))).add('1-1');
			System.assert(false, 'exception expected because the method is called more times than expected in the verification');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 5, Actual: 4 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatStrictVerificationCanBeEnforced()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(3))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(1))).add('2-1');
	}

	@isTest
	static void thatTimesOneIsTheDefaultVerification()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock)).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock)).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock)).add('1-1');
			System.assert(false, 'exception expected because the method is called more times than expected in the verification');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 1, Actual: 4 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatWithOldNotation()
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

		((fflib_MyList.IList)inOrder1.verify(firstMock, 3)).add('1-1');
	}

	@isTest
	static void thatWithOldNotationThrowsExceptionIfCalledMoreTimesThanExpected()
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
			((fflib_MyList.IList)inOrder1.verify(firstMock, 2)).add('1-1');
			System.assert(false, 'exception expected because the method is called more times than expected in the verification');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 2, Actual: 3 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatWithOldNotationThrowsExceptionIfCalledLessTimesThanExpected()
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
			((fflib_MyList.IList)inOrder1.verify(firstMock, 4)).add('1-1');
			System.assert(false, 'exception expected because the method is called more times than expected in the verification');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 4, Actual: 3 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatWithOldNotationPassWhenAnotherMethodIsCalledBetweenMethodsCalls()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		((fflib_MyList.IList)inOrder1.verify(firstMock, 4)).add('1-1');
	}

	@isTest
	static void thatWithOldNotationThrowsExceptionWhenAnotherMethodIsCalledBetweenMethodsCalls()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, 5)).add('1-1');
			System.assert(false, 'exception expected because the method is called more times than expected in the verification');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 5, Actual: 4 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void thatStrictVerificationCanBeEnforcedWithOldNotation()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, 1)).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, 1)).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, 3)).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, 1)).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, 1)).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, 1)).add('2-1');
	}

	@isTest
	static void thatStrictVerificationCanBeEnforcedWithOldNotationUsingDefaultTimesOne()
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
		firstMock.add('1-1');
		firstMock.add('2-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock)).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock)).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock, 3)).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock)).add('2-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock)).add('1-1');
		((fflib_MyList.IList)inOrder1.verify(firstMock)).add('2-1');
	}

	@isTest
	static void thatVerifyAtLeastConsumesAllTheInstances2()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		//When
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('1-1');
		firstMock.add('2-1');
		firstMock.add('2-1');
		firstMock.add('2-1');
		firstMock.add('2-1');
		firstMock.add('2-1');
		firstMock.add('1-1');

		// Then
		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(2))).add('1-1');

		try
		{
			((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(1))).add('2-1');
			System.assert(false, 'exception expected because the atLeast have consumed all the calls');
		}
		catch (fflib_ApexMocks.ApexMocksException mockExcept)
		{
			String expectedMessage = 'In Order: Expected : 1, Actual: 0 -- Wanted but not invoked: fflib_MyList__sfdc_ApexStub.add(String).';
			System.assertEquals(expectedMessage, mockExcept.getMessage(), ' the error message is not as expected');
		}
	}

	@isTest
	static void verifyAtLeastAndCapture()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		//When
		firstMock.get2(1, '1-1');
		firstMock.get2(2, '2-1');
		firstMock.get2(1, '3-1');
		firstMock.get2(1, '4-1');
		firstMock.get2(2, '5-1');

		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.atLeast(2))).get2( fflib_Match.eqInteger(1), (String) argument.capture());

		System.assertEquals('4-1', (string) argument.getValue(), 'the last value captured is not as expected');
	}

	@isTest
	static void verifyTimesAndCaptor()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		//When
		firstMock.get2(1, '1-1');
		firstMock.get2(2, '1-2');
		firstMock.get2(1, '2-1');
		firstMock.get2(2, '2-2');
		firstMock.get2(1, '3-1');
		firstMock.get2(2, '3-2');
		firstMock.get2(1, '4-1');
		firstMock.get2(2, '4-2');
		firstMock.get2(1, '5-1');
		firstMock.get2(2, '5-2');

		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.times(5))).get2(fflib_Match.eqInteger(1), (String) argument.capture());

		System.assertEquals('5-1', (string) argument.getValue(), 'the last value captured is not as expected');
	}

	@isTest
	static void verifyCallsAndCapture()
	{
		// Given
		fflib_MyList firstMock = (fflib_MyList)MY_MOCKS.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(MY_MOCKS, new List<Object>{ firstMock });

		//When
		firstMock.get2(1, '1-1');
		firstMock.get2(2, '1-2');
		firstMock.get2(1, '2-1');
		firstMock.get2(2, '2-2');
		firstMock.get2(1, '3-1');
		firstMock.get2(2, '3-2');
		firstMock.get2(1, '4-1');
		firstMock.get2(2, '4-2');
		firstMock.get2(1, '5-1');
		firstMock.get2(2, '5-2');

		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList)inOrder1.verify(firstMock, MY_MOCKS.calls(2))).get2(fflib_Match.eqInteger(1), (String) argument.capture());

		System.assertEquals('2-1', (string) argument.getValue(), 'the last value captured is not as expected');
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