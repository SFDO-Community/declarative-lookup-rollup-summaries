/*
 * Copyright (c) 2016, FinancialForce.com, inc
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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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
		fflib_MyList.IList mockList = new fflib_Mocks.Mockfflib_MyList(mocks);

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

	private class TestInnerClass
	{
		public Integer i;
		public String s;
	}
}