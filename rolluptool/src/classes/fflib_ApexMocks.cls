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
public with sharing class fflib_ApexMocks
{
	public static final Integer NEVER = 0;

	private final fflib_MethodCountRecorder methodCountRecorder;
	private final fflib_MethodReturnValueRecorder methodReturnValueRecorder;

	public Boolean Verifying
	{
		get
		{
			return methodCountRecorder.Verifying;
		}

		private set;
	}

	public Boolean Stubbing
	{
		get
		{
			return methodReturnValueRecorder.Stubbing;
		}

		private set;
	}

	public Exception DoThrowWhenException
	{
		get
		{
			return methodReturnValueRecorder.DoThrowWhenException;
		}

		set
		{
			methodReturnValueRecorder.DoThrowWhenException = value;
		}
	}

	/**
	 * Construct an ApexMocks instance.
	 */
	public fflib_ApexMocks()
	{
		methodCountRecorder = new fflib_MethodCountRecorder();
		methodReturnValueRecorder = new fflib_MethodReturnValueRecorder();

		methodCountRecorder.Verifying = false;
		methodReturnValueRecorder.Stubbing = false;
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
		return verify(mockInstance, 1);
	}

	/**
	 * Verify a method was called on a mock object.
	 * @param mockInstance The mock object instance.
	 * @param times The number of times you expect the method to have been called.
	 * @return The mock object instance.
	 */
	public Object verify(Object mockInstance, Integer times)
	{
		methodCountRecorder.Verifying = true;
		methodCountRecorder.VerifyCount = times;
		return mockInstance;
	}

	/**
	 * Verfiy a method was called on a mock object.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method you expect to have been called.
	 * @param methodArg The argument you expect to have been passed to the method being verified.
	 */
	public void verifyMethodCall(Object mockInstance, String methodName, Object methodArg)
	{
		methodCountRecorder.verifyMethodCall(mockInstance, methodName, methodArg);
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
	 * @param This is the return value from the method called on the mockInstance, and is ignored here since we are about to setup
	 *        the stubbed return value using thenReturn() (see MethodReturnValue class below).
	 */
	public fflib_MethodReturnValue when(Object ignoredRetVal)
	{
		return methodReturnValueRecorder.MethodReturnValue;
	}

	/**
	 * Record a method was called on a mock object.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method to be recorded.
	 * @param methodArg The method argument to be recorded.
	 */
	public void recordMethod(Object mockInstance, String methodName, Object methodArg)
	{
		methodCountRecorder.recordMethod(mockInstance, methodName, methodArg);
	}

	/**
	 * Prepare a stubbed method return value.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method for which to prepare a return value.
	 * @param methodArg The method argument for which to prepare a return value.
	 */
	public fflib_MethodReturnValue prepareMethodReturnValue(Object mockInstance, String methodName, Object methodArg)
	{
		return methodReturnValueRecorder.prepareMethodReturnValue(mockInstance, methodName, methodArg);
	}

	/**
	 * Get the method return value for the given method call.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method for which to prepare a return value.
	 * @param methodArg The method argument for which to prepare a return value.
	 * @return The MethodReturnValue instance.
	 */
	public fflib_MethodReturnValue getMethodReturnValue(Object mockInstance, String methodName, Object methodArg)
	{
		return methodReturnValueRecorder.getMethodReturnValue(mockInstance, methodName, methodArg);
	}

	/**
	 * Setup exception stubbing for a void method.
	 * @param e The exception to throw.
	 * @param mockInstance The mock object instance.
	 */
	public Object doThrowWhen(Exception e, Object mockInstance)
	{
		methodReturnValueRecorder.prepareDoThrowWhenException(e);
		return mockInstance;
	}

	/**
	 * Mock a void method. Called by generated mock instance classes, not directly by a developers
	 * code.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method for which to prepare a return value.
	 * @param methodArg The method argument for which to prepare a return value.
	 */
	public void mockVoidMethod(Object mockInstance, String methodName, Object methodArg)
	{
		if (Verifying)
		{
			verifyMethodCall(mockInstance, methodName, methodArg);
		}
		else if (Stubbing)
		{
			prepareMethodReturnValue(mockInstance, methodName, methodArg).thenThrow(DoThrowWhenException);
		}
		else
		{
			fflib_MethodReturnValue methodReturnValue = getMethodReturnValue(mockInstance, methodName, methodArg);

			if (methodReturnValue != null && methodReturnValue.ReturnValue instanceof Exception)
			{
				throw ((Exception) methodReturnValue.ReturnValue);
			}

			recordMethod(mockInstance, methodName, methodArg);
		}
	}

	/**
	 * Mock a non-void method. Called by generated mock instance classes, not directly by a developers
	 * code.
	 * @param mockInstance The mock object instance.
	 * @param methodName The method for which to prepare a return value.
	 * @param methodArg The method argument for which to prepare a return value.
	 */
	public Object mockNonVoidMethod(Object mockInstance, String methodName, Object methodArg)
	{
		if (Verifying)
		{
			verifyMethodCall(mockInstance, methodName, methodArg);
		}
		else if (Stubbing)
		{
			prepareMethodReturnValue(mockInstance, methodName, methodArg);
			return null;
		}
		else
		{
			recordMethod(mockInstance, methodName, methodArg);

			fflib_MethodReturnValue methodReturnValue = getMethodReturnValue(mockInstance, methodName, methodArg);

			if (methodReturnValue != null)
			{
				if (methodReturnValue.ReturnValue instanceof Exception)
				{
					throw ((Exception) methodReturnValue.ReturnValue);
				}

				return methodReturnValue.ReturnValue;
			}
		}

		return null;
	}
}