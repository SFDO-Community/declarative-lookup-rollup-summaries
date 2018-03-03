/*
 * Copyright (c) 2016-2017 FinancialForce.com, inc.  All rights reserved.
 */
/**
 * @nodoc
 */
@isTest
private class fflib_ArgumentCaptorTest
{
	@isTest
	static void thatArgumentValueIsCaptured()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Fred');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);
		((fflib_MyList.IList) mocks.verify(mockList)).add((String) argument.capture());

		System.assertEquals('Fred', (String)argument.getValue(), 'the argument captured is not as expected');
	}

	@isTest
	static void thatCanPerformFurtherAssertionsOnCapturedArgumentValue()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		//When
		TestInnerClass testValue = new TestInnerClass();
		testValue.i = 4;
		testValue.s = '5';

		mockList.set(1, testValue);

		//Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(TestInnerClass.class);

		((fflib_MyList.IList) mocks.verify(mockList)).set(fflib_Match.anyInteger(),  argument.capture());

		Object capturedArg = argument.getValue();
		System.assertNotEquals(null, capturedArg, 'CapturedArg should not be null');

		System.assert(capturedArg instanceof TestInnerClass, 'CapturedArg should be SObject, instead was ' + capturedArg);

		TestInnerClass testValueCaptured = (TestInnerClass)capturedArg;

		System.assertEquals(4, testValueCaptured.i, 'the values inside the argument captured should be the same of the original one');
		System.assertEquals('5', testValueCaptured.s, 'the values inside the argument captured should be the same of the original one');
	}

	@isTest
	static void thatCaptureArgumentOnlyFromVerifiedMethod()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Fred');
		//the next call should be ignored because is not the method that has under verify,
		//even if have the same type specified in the capturer.
		mockList.addMore('Barney');

		// Then

		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);
		((fflib_MyList.IList) mocks.verify(mockList)).add((String) argument.capture());

		System.assertEquals('Fred', (String)argument.getValue(), 'the argument captured is not as expected');
		System.assertEquals(1, argument.getAllValues().size(), 'the argument captured should be only one');
	}

	@isTest
	static void thatCaptureAllArgumentsForTheVerifiedMethods()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		List<String> stringList = new List<String> {'3'};
		// When
		mockList.add('Fred');
		mockList.add(stringList);

		mockList.clear();

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList)).add((String) argument.capture());
		((fflib_MyList.IList) mocks.verify(mockList)).add((List<String>) argument.capture());

		System.assertEquals(stringList, (List<String>)argument.getValue(), 'the argument captured is not as expected');

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(2, argsCaptured.size(), 'expected 2 argument to be captured');

		System.assertEquals('Fred', (String) argsCaptured[0], 'the first value is not as expected');
	}

	@isTest
	static void thatCaptureArgumentFromRequestedParameter()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Fred', 'Barney', 'Wilma', 'Betty');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList))
			.add(
				(String) fflib_Match.eq('Fred'),
				(String) fflib_Match.eq('Barney'),
				(String)  argument.capture(),
				(String) fflib_Match.eq('Betty'));

		System.assertEquals('Wilma', (String)argument.getValue(),
			'the argument captured is not as expected, should be Wilma because is the 3rd parameter in the call');
	}

	@isTest
	static void thatCaptureLastArgument()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Barney');
		mockList.add('Fred');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList, 2)).add((String) argument.capture());

		System.assertEquals('Fred', (String)argument.getValue(), 'the argument captured is not as expected');
	}

	@isTest
	static void thatCaptureAllArguments()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Fred');
		mockList.add('Barney');
		mockList.add('Wilma');
		mockList.add('Betty');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList, 4)).add((String) argument.capture());

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(4, argsCaptured.size(), 'expected 4 argument to be captured');

		System.assertEquals('Fred', (String) argsCaptured[0], 'the first value is not as expected');
		System.assertEquals('Barney', (String) argsCaptured[1], 'the second value is not as expected');
		System.assertEquals('Wilma', (String) argsCaptured[2], 'the third value is not as expected');
		System.assertEquals('Betty', (String) argsCaptured[3], 'the forth value is not as expected');
	}

	@isTest
	static void thatCaptureAllArgumentsFromMultipleMethods()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Fred');
		mockList.add('Barney');
		mockList.get2(3, 'pebble');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList, 2)).add((String) argument.capture());

		((fflib_MyList.IList) mocks.verify(mockList))
			.get2(
				(Integer) fflib_Match.eq(3),
				(String) argument.capture());

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(3, argsCaptured.size(), 'expected 3 argument to be captured');

		System.assertEquals('Fred', (String) argsCaptured[0], 'the first value is not as expected');
		System.assertEquals('Barney', (String) argsCaptured[1], 'the second value is not as expected');

		System.assertEquals('pebble', (String) argsCaptured[2], 'the third value is not as expected');
	}

	@isTest
	static void thatCanHandleMultipleCapturesInOneMethodCall()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Fred', 'Barney', 'Wilma', 'Betty');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList))
			.add(
				(String) fflib_Match.eq('Fred'),
				(String)  argument.capture(),
				(String)  argument.capture(),
				(String) fflib_Match.eq('Betty'));

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(2, argsCaptured.size(), 'expected 2 argument to be captured');

		System.assertEquals('Barney', (String) argsCaptured[0], 'the first value is not as expected');

		System.assertEquals('Wilma', (String) argsCaptured[1], 'the second value is not as expected');
	}

	@isTest
	static void thatDoesNotCaptureIfNotVerified()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('3');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(List<String>.class);

		((fflib_MyList.IList) mocks.verify(mockList, fflib_ApexMocks.NEVER))
			.add((List<String>) argument.capture());

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(0, argsCaptured.size(), 'expected 0 argument to be captured');

		System.assertEquals(null, argument.getValue(), 'no value should be captured, so must return null');
	}

	@isTest
	static void thatCaptureOnlyMethodsThatMatchesWithOtherMatcherAsWell()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Same', 'Same', 'First call', 'First call');
		mockList.add('Same', 'Same', 'Second call', 'Second call');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList)).add(
			fflib_Match.eqString('Same'),
			fflib_Match.eqString('Same'),
			(String)argument.capture(),
			fflib_Match.eqString('First call'));

		System.assertEquals('First call', (String)argument.getValue());
	}

	@isTest
	static void thatDoesNotCaptureAnythingWhenCaptorIsWrappedInAMatcher()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Same', 'Same', 'First call', 'First call');
		mockList.add('Same', 'Same', 'Second call', 'Second call');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList)).add(
			(String) fflib_Match.allOf(
				fflib_Match.eqString('Same'),
				fflib_Match.eqString('Same'),
				argument.capture()),
			(String) fflib_Match.allOf(
				fflib_Match.eqString('Same'),
				fflib_Match.eqString('Same'),
				argument.capture()),
			(String) fflib_Match.allOf(
				argument.capture(),
				fflib_Match.eqString('First call')),
			(String) fflib_Match.allOf(
				argument.capture(),
				fflib_Match.eqString('First call'))
			);

		List<Object> capturedValues = argument.getAllValues();

		System.assertEquals(0, capturedValues.size(),
			'nothing should have been capture because the matcher it not really a capture type, but a allOf()');
		System.assertEquals(null, (String)argument.getValue(),
			'nothing should have been capture because the matcher it not really a capture type, but a allOf()');
	}

	@isTest
	static void thatArgumentValueIsCapturedWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });

		// When
		mockList.add('Fred');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList)inOrder1.verify(mockList, mocks.calls(1))).add((String) argument.capture());

		System.assertEquals('Fred', (String)argument.getValue(), 'the argument captured is not as expected');
	}

	@isTest
	static void thatCanPerformFurtherAssertionsOnCapturedArgumentValueWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		//When
		TestInnerClass testValue = new TestInnerClass();
		testValue.i = 4;
		testValue.s = '5';

		mockList.set(1, testValue);

		//Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(TestInnerClass.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1))).set(fflib_Match.anyInteger(),  argument.capture());

		Object capturedArg = argument.getValue();
		System.assertNotEquals(null, capturedArg, 'CapturedArg should not be null');

		System.assert(capturedArg instanceof TestInnerClass, 'CapturedArg should be SObject, instead was ' + capturedArg);

		TestInnerClass testValueCaptured = (TestInnerClass)capturedArg;

		System.assertEquals(4, testValueCaptured.i, 'the values inside the argument captured should be the same of the original one');
		System.assertEquals('5', testValueCaptured.s, 'the values inside the argument captured should be the same of the original one');
	}

	@isTest
	static void thatCaptureArgumentOnlyFromVerifiedMethodWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('Fred');
		//the next call should be ignored because is not the method that has under verify,
		//even if have the same type specified in the capturer.
		mockList.addMore('Barney');

		// Then

		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);
		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1))).add((String) argument.capture());

		System.assertEquals('Fred', (String)argument.getValue(), 'the argument captured is not as expected');
		System.assertEquals(1, argument.getAllValues().size(), 'the argument captured should be only one');
	}

	@isTest
	static void thatCaptureAllArgumentsForTheVerifiedMethodsWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		List<String> stringList = new List<String> {'3'};
		// When
		mockList.add('Fred');
		mockList.add(stringList);

		mockList.clear();

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1))).add((String) argument.capture());
		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1))).add((List<String>) argument.capture());

		System.assertEquals(stringList, (List<String>)argument.getValue(), 'the argument captured is not as expected');

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(2, argsCaptured.size(), 'expected 2 argument to be captured');

		System.assertEquals('Fred', (String) argsCaptured[0], 'the first value is not as expected');
	}

	@isTest
	static void thatCaptureArgumentFromRequestedParameterWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('Fred', 'Barney', 'Wilma', 'Betty');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1)))
			.add(
				(String) fflib_Match.eq('Fred'),
				(String) fflib_Match.eq('Barney'),
				(String)  argument.capture(),
				(String) fflib_Match.eq('Betty'));

		System.assertEquals('Wilma', (String)argument.getValue(),
			'the argument captured is not as expected, should be Wilma because is the 3rd parameter in the call');
	}

	@isTest
	static void thatCaptureLastArgumentWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('Barney');
		mockList.add('Fred');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(2))).add((String) argument.capture());

		System.assertEquals('Fred', (String)argument.getValue(), 'the argument captured is not as expected');
	}

	@isTest
	static void thatCaptureAllArgumentsWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('Fred');
		mockList.add('Barney');
		mockList.add('Wilma');
		mockList.add('Betty');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(4))).add((String) argument.capture());

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(4, argsCaptured.size(), 'expected 4 argument to be captured');

		System.assertEquals('Fred', (String) argsCaptured[0], 'the first value is not as expected');
		System.assertEquals('Barney', (String) argsCaptured[1], 'the second value is not as expected');
		System.assertEquals('Wilma', (String) argsCaptured[2], 'the third value is not as expected');
		System.assertEquals('Betty', (String) argsCaptured[3], 'the forth value is not as expected');
	}

	@isTest
	static void thatCaptureAllArgumentsFromMultipleMethodsWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('Fred');
		mockList.add('Barney');
		mockList.get2(3, 'pebble');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(2))).add((String) argument.capture());

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1)))
			.get2(
				(Integer) fflib_Match.eq(3),
				(String) argument.capture());

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(3, argsCaptured.size(), 'expected 3 argument to be captured');

		System.assertEquals('Fred', (String) argsCaptured[0], 'the first value is not as expected');
		System.assertEquals('Barney', (String) argsCaptured[1], 'the second value is not as expected');

		System.assertEquals('pebble', (String) argsCaptured[2], 'the third value is not as expected');
	}

	@isTest
	static void thatCanHandleMultipleCapturesInOneMethodCallWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('Fred', 'Barney', 'Wilma', 'Betty');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1)))
			.add(
				(String) fflib_Match.eq('Fred'),
				(String)  argument.capture(),
				(String)  argument.capture(),
				(String) fflib_Match.eq('Betty'));

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(2, argsCaptured.size(), 'expected 2 argument to be captured');

		System.assertEquals('Barney', (String) argsCaptured[0], 'the first value is not as expected');

		System.assertEquals('Wilma', (String) argsCaptured[1], 'the second value is not as expected');
	}

	@isTest
	static void thatDoesNotCaptureIfNotVerifiedWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('3');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(List<String>.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.never()))
			.add((List<String>) argument.capture());

		List<Object> argsCaptured = argument.getAllValues();

		System.assertEquals(0, argsCaptured.size(), 'expected 0 argument to be captured');

		System.assertEquals(null, argument.getValue(), 'no value should be captured, so must return null');
	}

	@isTest
	static void thatCaptureOnlyMethodsThatMatchesWithOtherMatcherAsWellWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('Same', 'Same', 'First call', 'First call');
		mockList.add('Same', 'Same', 'Second call', 'Second call');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1))).add(
			fflib_Match.eqString('Same'),
			fflib_Match.eqString('Same'),
			(String)argument.capture(),
			fflib_Match.eqString('First call'));

		System.assertEquals('First call', (String)argument.getValue());
	}

	@isTest
	static void thatDoesNotCaptureAnythingWhenCaptorIsWrappedInAMatcherWithInOrderVerification()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);
		fflib_InOrder inOrder1 = new fflib_InOrder(mocks, new List<Object>{ mockList });


		// When
		mockList.add('Same', 'Same', 'First call', 'First call');
		mockList.add('Same', 'Same', 'Second call', 'Second call');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) inOrder1.verify(mockList, mocks.calls(1))).add(
			(String) fflib_Match.allOf(
				fflib_Match.eqString('Same'),
				fflib_Match.eqString('Same'),
				argument.capture()),
			(String) fflib_Match.allOf(
				fflib_Match.eqString('Same'),
				fflib_Match.eqString('Same'),
				argument.capture()),
			(String) fflib_Match.allOf(
				argument.capture(),
				fflib_Match.eqString('First call')),
			(String) fflib_Match.allOf(
				argument.capture(),
				fflib_Match.eqString('First call'))
			);

		List<Object> capturedValues = argument.getAllValues();

		System.assertEquals(0, capturedValues.size(),
			'nothing should have been capture because the matcher it not really a capture type, but a allOf()');
		System.assertEquals(null, (String)argument.getValue(),
			'nothing should have been capture because the matcher it not really a capture type, but a allOf()');
	}

	@isTest
	static void thatCaptureAllArgumentswhenMethodIsCalledWithTheSameArgument()
	{
		// Given
		fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_MyList mockList = (fflib_MyList)mocks.mock(fflib_MyList.class);

		// When
		mockList.add('Fred');
		mockList.add('Barney');
		mockList.add('Wilma');
		mockList.add('Barney');
		mockList.add('Barney');
		mockList.add('Betty');

		// Then
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(String.class);

		((fflib_MyList.IList) mocks.verify(mockList, 6)).add((String) argument.capture());

		List<object> argsCaptured = argument.getAllValues();

		System.assertEquals(6, argsCaptured.size(), 'expected 6 arguments to be captured');

		System.assertEquals('Fred', (String) argsCaptured[0], 'the first value is not as expected');
		System.assertEquals('Barney', (String) argsCaptured[1], 'the second value is not as expected');
		System.assertEquals('Wilma', (String) argsCaptured[2], 'the third value is not as expected');
		System.assertEquals('Barney', (String) argsCaptured[3], 'the fourth value is not as expected');
		System.assertEquals('Barney', (String) argsCaptured[4], 'the fifth value is not as expected');
		System.assertEquals('Betty', (String) argsCaptured[5], 'the sixth value is not as expected');
	}


	private class TestInnerClass
	{
		public Integer i;
		public String s;
	}
}