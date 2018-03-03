/*
 Copyright (c) 2014-2017 FinancialForce.com, inc.  All rights reserved.
 */

/**
 * @group Core
 */
public with sharing class fflib_ApexMocks implements System.StubProvider
{
	public static final Integer NEVER = 0;

	private final fflib_MethodCountRecorder methodCountRecorder;
	private final fflib_MethodReturnValueRecorder methodReturnValueRecorder;

	private fflib_MethodVerifier methodVerifier;
	private fflib_VerificationMode verificationMode;
	private fflib_Answer myAnswer;

	public Boolean Verifying { get; set; }

	public Boolean Stubbing
	{
		get
		{
			return methodReturnValueRecorder.Stubbing;
		}

		private set;
	}

	public List<Exception> DoThrowWhenExceptions
	{
		get
		{
			return methodReturnValueRecorder.DoThrowWhenExceptions;
		}

		set
		{
			methodReturnValueRecorder.DoThrowWhenExceptions = value;
		}
	}

	/**
	 * Construct an ApexMocks instance.
	 */
	public fflib_ApexMocks()
	{
		Verifying = false;

		this.methodCountRecorder = new fflib_MethodCountRecorder();
		this.verificationMode = new fflib_VerificationMode();
		this.methodVerifier = new fflib_AnyOrder();

		this.methodReturnValueRecorder = new fflib_MethodReturnValueRecorder();

		this.methodReturnValueRecorder.Stubbing = false;
	}

	/**
     * Creates mock object of given class or interface.
     * @param classToMock class or interface to mock.
     * @return mock object.
     */
	public Object mock(Type classToMock)
	{
		return Test.createStub(classToMock, this);
	}

	/**
	 * Inherited from StubProvider.
	 * @param stubbedObject The stubbed object.
	 * @param stubbedMethodName The name of the invoked method.
	 * @param returnType The return type of the invoked method.
	 * @param listOfParamTypes A list of the parameter types of the invoked method.
	 * @param listOfParamNames A list of the parameter names of the invoked method.
	 * @param listOfArgs The actual argument values passed into this method at runtime.
	 * @return The stubbed return value. Null by default, unless you prepared one that matches this method and argument values in stubbing.
	 */
	public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
		List<type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs)
    {
        return mockNonVoidMethod(stubbedObject, stubbedMethodName, listOfParamTypes, listOfArgs);
    }

	public static String extractTypeName(Object mockInstance)
	{
		return String.valueOf(mockInstance).split(':').get(0);
	}

	/**
	 * Verify a method was called on a mock object.
	 * @param mockInstance The mock object instance.
	 * @return The mock object instance.
	 */
	public Object verify(Object mockInstance)
	{
		return verify(mockInstance, this.times(1));
	}

	/**
	 * Verify a method was called on a mock object.
	 * @param mockInstance The mock object instance.
	 * @param verificationMode Defines the constraints for performing the verification (e.g. the minimum and maximum expected invocation counts).
	 * @return The mock object instance.
	 */
	public Object verify(Object mockInstance, fflib_VerificationMode verificationMode)
	{
		Verifying = true;
		this.verificationMode = verificationMode;

		return mockInstance;
	}

	/**
	 * Verify a method was called on a mock object.
	 * @param mockInstance The mock object instance.
	 * @param times The number of times you expect the method to have been called.
	 * @return The mock object instance.
	 */
	public Object verify(Object mockInstance, Integer times)
	{
		return verify(mockInstance, this.times(times));
	}

	/**
	 * Verfiy a method was called on a mock object.
	 * @param mockInvocation The invocation on the mock containing information about the method and the arguments.
	 */
	public void verifyMethodCall(fflib_InvocationOnMock mockInvocation)
	{
		this.methodVerifier.verifyMethodCall(mockInvocation, verificationMode);
		this.methodVerifier = new fflib_AnyOrder();

		Verifying = false;
	}

	/**
	 * Tell ApexMocks framework you are about to start stubbing using when() calls.
	 */
	public void startStubbing()
	{
		methodReturnValueRecorder.Stubbing = true;
	}

	/**
	 * Tell ApexMocks framework you are about to stop stubbing using when() calls.
	 */
	public void stopStubbing()
	{
		methodReturnValueRecorder.Stubbing = false;
	}

	/**
	 * Setup when stubbing for a mock object instance.
	 * @param ignoredRetVal This is the return value from the method called on the mockInstance, and is ignored here since we are about to setup
	 *        the stubbed return value using thenReturn() (see MethodReturnValue class below).
	 */
	public fflib_MethodReturnValue when(Object ignoredRetVal)
	{
		return methodReturnValueRecorder.MethodReturnValue;
	}

	/**
	 * Record a method was called on a mock object.
	 * @param mockInvocation The invocation on the mock containing information about the method and the arguments.
	 */
	public void recordMethod(fflib_InvocationOnMock mockInvocation)
	{
		methodCountRecorder.recordMethod(mockInvocation);
	}

	/**
	 * Prepare a stubbed method return value.
	 * @param mockInvocation The invocation on the mock containing information about the method and the arguments.
	 * @return The MethodReturnValue instance.
	 */
	public fflib_MethodReturnValue prepareMethodReturnValue(fflib_InvocationOnMock mockInvocation)
	{
		return methodReturnValueRecorder.prepareMethodReturnValue(mockInvocation);
	}

	/**
	 * Get the method return value for the given method call.
	 * @param mockInvocation The invocation on the mock containing information about the method and the arguments.
	 * @return The MethodReturnValue instance.
	 */
	public fflib_MethodReturnValue getMethodReturnValue(fflib_InvocationOnMock mockInvocation)
	{
		return methodReturnValueRecorder.getMethodReturnValue(mockInvocation);
	}

	/**
	 * Setup exception stubbing for a void method.
	 * @param e The exception to throw.
	 * @param mockInstance The mock object instance.
	 */
	public Object doThrowWhen(Exception e, Object mockInstance)
	{
		methodReturnValueRecorder.prepareDoThrowWhenExceptions(new List<Exception>{e});
		return mockInstance;
	}

	/**
	 * Setup exception stubbing for a void method.
	 * @param exps The list of exceptions to throw.
	 * @param mockInstance The mock object instance.
	 */
	public Object doThrowWhen(List<Exception> exps, Object mockInstance)
	{
		methodReturnValueRecorder.prepareDoThrowWhenExceptions(exps);
		return mockInstance;
	}

	/**
	 * Setup answer stubbing for a void method.
	 * @param answer The answer to invoke.
	 * @param mockInstance The mock object instance.
	 */
	public Object doAnswer(fflib_Answer answer, Object mockInstance)
	{
		this.myAnswer = answer;
		return mockInstance;
	}

	/**
	 * Mock a void method. Called by generated mock instance classes, not directly by a developers
	 * code.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method for which to prepare a return value.
	 * @param methodArgTypes The method argument types for which to prepare a return value.
	 * @param methodArgValues The method argument values for which to prepare a return value.
	 */
	public void mockVoidMethod(Object mockInstance, String methodName, List<Type> methodArgTypes, List<Object> methodArgValues)
	{
		mockNonVoidMethod(mockInstance, methodName, methodArgTypes, methodArgValues);
	}

	/**
	 * Mock a non-void method. Called by generated mock instance classes, not directly by a developers
	 * code.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method for which to prepare a return value.
	 * @param methodArgTypes The method argument types for which to prepare a return value.
	 * @param methodArgValues The method argument values for which to prepare a return value.
	 */
	public Object mockNonVoidMethod(Object mockInstance, String methodName, List<Type> methodArgTypes, List<Object> methodArgValues)
	{
		fflib_QualifiedMethod qm = new fflib_QualifiedMethod(extractTypeName(mockInstance), methodName, methodArgTypes, mockInstance);
		fflib_MethodArgValues argValues = new fflib_MethodArgValues(methodArgValues);

		fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, argValues, mockInstance);

		if (Verifying)
		{
			verifyMethodCall(invocation);
		}
		else if (Stubbing)
		{
			fflib_MethodReturnValue methotReturnValue = prepareMethodReturnValue(invocation);

			if(DoThrowWhenExceptions != null)
			{
				methotReturnValue.thenThrowMulti(DoThrowWhenExceptions);
				DoThrowWhenExceptions = null;
				return null;
			}

			if(this.myAnswer != null)
			{
				methotReturnValue.thenAnswer(this.myAnswer);
				this.myAnswer = null;
				return null;
			}

			return null;
		}
		else
		{
			recordMethod(invocation);
			return returnValue(invocation);
		}

		return null;
	}

	public class ApexMocksException extends Exception
	{

	}

	private Object returnValue(fflib_InvocationOnMock invocation)
	{
		fflib_MethodReturnValue methodReturnValue = getMethodReturnValue(invocation);

		if (methodReturnValue != null)
		{
			if(methodReturnValue.Answer == null)
			{
				throw new fflib_ApexMocks.ApexMocksException(
  					'The stubbing is not correct, no return values have been set.');
			}

			Object returnedValue = methodReturnValue.Answer.answer(invocation);

			if(returnedValue == null)
			{
				return null;
			}

			if (returnedValue instanceof Exception)
			{
				throw ((Exception) returnedValue);
			}

			return returnedValue;
		}

		return null;
	}

	/**
	 * Sets how many times the method is expected to be called.
	 * For InOrder verification we copy Mockito behavior which is as follows;
	 * <ul>
	 * <li>Consume the specified number of matching invocations, ignoring non-matching invocations in between</li>
	 * <li>Fail an assert if the very next invocation matches, but additional matches can still exist so long as at least one non-matching invocation exists before them</li>
	 * </ul>
	 * For example if you had a(); a(); b(); a();
	 * then inOrder.verify(myMock, 2)).a(); or inOrder.verify(myMock, 3)).a(); would pass but not inOrder.verify(myMock, 1)).a();
	 * @param times The number of times you expect the method to have been called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode times(Integer times)
	{
		return new fflib_VerificationMode().times(times);
	}

	/**
	 * Sets how many times the method is expected to be called for an InOrder verifier. Available Only with the InOrder verification.
	 * A verification mode using calls will not fail if the method is called more times than expected.
	 * @param times The number of times you expect the method to have been called in the InOrder verifying ( no greedy verify).
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode calls(Integer times)
	{
		return new fflib_VerificationMode().calls(times);
	}

	/**
	 * Sets a custom assert message for the verify.
	 * @param customAssertMessage The custom message for the assert in case the assert is false. The custom message is queued to the default message.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode description(String customAssertMessage)
	{
		return new fflib_VerificationMode().description(customAssertMessage);
	}

	/**
	 * Sets the minimum number of times the method is expected to be called.
	 * With the InOrder verification it performs a greedy verification, which means it would consume all the instances of the method verified.
	 * @param atLeastTimes The minimum number of times you expect the method to have been called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode atLeast(Integer atLeastTimes)
	{
		return new fflib_VerificationMode().atLeast(atLeastTimes);
	}

	/**
	 * Sets the maximum number of times the method is expected to be called. Not available in the InOrder verification.
	 * @param atMostTimes The maximum number of times the method is expected to be called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode atMost(Integer atMostTimes)
	{
		return new fflib_VerificationMode().atMost(atMostTimes);
	}

	/**
	 * Sets that the method is called at least once.
	 * With the InOrder verification it performs a greedy verification, which means it would consume all the instances of the method verified.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode atLeastOnce()
	{
		return new fflib_VerificationMode().atLeastOnce();
	}

	/**
	 * Sets the range of how many times the method is expected to be called. Not available in the InOrder verification.
	 * @param atLeastTimes The minimum number of times you expect the method to have been called.
	 * @param atMostTimes The maximum number of times the method is expected to be called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode between(Integer atLeastTimes, Integer atMostTimes)
	{
		return new fflib_VerificationMode().between(atLeastTimes, atMostTimes);
	}

	/**
	 * Sets that the method is not expected to be called.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public fflib_VerificationMode never()
	{
		return new fflib_VerificationMode().never();
	}

	/**
	 * Sets the fflib_VerificationMode object.
	 * To internal use only.
	 * Used to pass the verification mode that has been set in the  verify of the fflib_InOrder class.
	 * @return The fflib_VerificationMode object instance with the proper settings.
	 */
	public void setOrderedVerifier(fflib_InOrder verifyOrderingMode)
	{
		this.methodVerifier = verifyOrderingMode;
	}
}
