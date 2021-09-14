/*
 Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */


/**
 * @group Core
 */
public with sharing class fflib_InOrder extends fflib_MethodVerifier
{
	private final List<Object> unorderedMockInstances;
	private Integer idxMethodCall = 0;

	private Set<fflib_VerificationMode.ModeName> notImplementedMethods =
		new Set<fflib_VerificationMode.ModeName>
		{
			fflib_VerificationMode.ModeName.atMost,
			fflib_VerificationMode.ModeName.between
		};

	private final fflib_ApexMocks mocks;

	/**
	 * Construct the InOrder instance.
	 * @param mocks The apex mock object instance.
	 * @param unorderedMockInstances One or more mock implementation classes (listed in any order), whose ordered method calls require verification.
	 */
	public fflib_InOrder(fflib_ApexMocks mocks, List<Object> unorderedMockInstances)
	{
		this.unorderedMockInstances = unorderedMockInstances;
		this.mocks = mocks;
	}

	/**
	 * Verify a method was called on a mock object.
	 * It performs a no strict ordered verification.
	 * The verification could be either greedy or not depending of the verificationMode passed.
	 * Check the fflib_VerificationMode methods for details.
	 * @param mockInstance The mock object instance.
	 * @param verificationMode Defines the constraints for performing the verification (e.g. the minimum and maximum expected invocation counts).
	 * @return The mock object instance.
	 */
	public Object verify(Object mockInstance, fflib_VerificationMode verificationMode)
	{
		mocks.setOrderedVerifier(this);
		return mocks.verify(mockInstance, verificationMode);
	}

	/**
	 * Verify a method was called on a mock object.
	 * It performs the default times(1) verification for the InOrder.
	 * @param mockInstance The mock object instance.
	 * @return The mock object instance.
	 */
	public Object verify(Object mockInstance)
	{
		mocks.setOrderedVerifier(this);
		return mocks.verify(mockInstance);
	}

	/**
	 * Verify a method was called on a mock object.
	 * Wrapper for the new syntax call to be conformed to the old style notation
	 * It performs the equivalent of times(times) verification for the InOrder.
	 * @param mockInstance The mock object instance.
	 * @param times The number of times you expect the method to have been called.
	 * @return The mock object instance.
	 */
	public Object verify(Object mockInstance, Integer times)
	{
		mocks.setOrderedVerifier(this);
		return mocks.verify(mockInstance, times);
	}

	/**
	 * Verify that after the last successful verified method no more interactions happened on the inOrderMock instance.
	 * @throws Exception with message to help to identify the last method called.
	 */
	public void verifyNoMoreInteractions()
	{
		if(idxMethodCall == 0)
		{
			verifyNoInteractions();
		}

		if(hasNextInteraction(unorderedMockInstances, idxMethodCall))
		{
			fflib_InvocationOnMock invocation =
				fflib_MethodCountRecorder.getOrderedMethodCalls().get(idxMethodCall -1);

			throw new fflib_ApexMocks.ApexMocksException(
				'No more Interactions were expected after the ' + invocation.getMethod() +' method.');
		}
	}

	/**
	 * Verify that no interactions at all happened on the inOrderMock instance.
	 * @throws Exception with message.
	 */
	public void verifyNoInteractions()
	{
		if(hasNextInteraction(unorderedMockInstances, 0))
		{
			throw new fflib_ApexMocks.ApexMocksException(
				'No Interactions expected on this InOrder Mock instance!');
		}
	}

	/*
	 * Verifies a method was invoked the expected number of times, with the expected arguments.
	 * The in-order verifier remembers the last method invocation it successfully verified,
	 * and only considers subsequent method invocations for subsequent verifications.
	 * @param qualifiedMethod The method to be verified.
	 * @param methodArg The arguments of the method that needs to be verified.
	 * @param verificationMode The verification mode that holds the setting about how the verification should be performed.
	 */
	protected override void verify(
		fflib_QualifiedMethod qm,
		fflib_MethodArgValues methodArg,
		fflib_VerificationMode verificationMode)
	{
		String inOrder = 'In Order: ';
		List<fflib_IMatcher> matchers = fflib_Match.Matching ? fflib_Match.getAndClearMatchers(methodArg.argValues.size()) : null;

		if( verificationMode.VerifyMin == 0 && verificationMode.VerifyMax == 0)
		{
			Integer methodCounts = countInteractions(matchers, qm, methodArg);
			if(methodCounts != 0 )
				throwException(qm, inOrder, fflib_ApexMocks.NEVER, '', methodCounts, verificationMode.CustomAssertMessage);
		}

		Integer i=0;
		for ( ; i<verificationMode.VerifyMin; i++)
		{
			if(!verifyMethodCalled(matchers, qm, methodArg))
			{
				throwException(qm, inOrder, verificationMode.VerifyMin, '', i, verificationMode.CustomAssertMessage);
			}
		}

		if( verificationMode.VerifyMin == verificationMode.VerifyMax )
		{
			if(hasNextInteraction(unorderedMockInstances, idxMethodCall))
			{
				fflib_InvocationOnMock nextMethod = getNextMethodCall(false);

				if(nextMethod.getMethod() == qm &&
					argumentsMatch(nextMethod.getMethodArgValues(), matchers, methodArg))
				{
					Integer methodCounts = i + countInteractions(matchers, qm, methodArg);
					throwException(qm, inOrder, verificationMode.VerifyMin, '', methodCounts, verificationMode.CustomAssertMessage);
				}
			}

			return;
		}

		//consuming all the calls in case is the atLeast or atLeastOnce method
		if(verificationMode.Method == fflib_VerificationMode.ModeName.atLeast
			|| verificationMode.Method == fflib_VerificationMode.ModeName.atLeastOnce)
		{
			consumeInteractions(matchers, qm, methodArg);
		}
	}

	private Boolean verifyMethodCalled(
		List<fflib_IMatcher> matchers,
		fflib_QualifiedMethod qm,
		fflib_MethodArgValues methodArg)
	{
		fflib_InvocationOnMock calledMethod = getNextMethodCall();
		while(calledMethod != null)
		{
			if(calledMethod.getMethod() == qm &&
				argumentsMatch(calledMethod.getMethodArgValues(), matchers, methodArg))
			{
				//it's our method
				if (matchers != null)
				{
					capture(matchers);
				}
				return true;
			}

			calledMethod = getNextMethodCall();
		}

		return false;
	}

	private Integer countInteractions(
		List<fflib_IMatcher> matchers,
		fflib_QualifiedMethod qualifiedMethod,
		fflib_MethodArgValues methodArg)
	{
		Integer interactionsCouter = 0;

		for (Integer i = idxMethodCall, len = fflib_MethodCountRecorder.getOrderedMethodCalls().size(); i<len; i++)
		{
			fflib_InvocationOnMock invocation = fflib_MethodCountRecorder.getOrderedMethodCalls().get(i);
			for (Object mockInstance : unorderedMockInstances)
			{
				if (invocation.getMock() === mockInstance
					&& (qualifiedMethod == invocation.getMethod())
					&& (argumentsMatch(invocation.getMethodArgValues(), matchers, methodArg)))
				{
					interactionsCouter++;
				}
			}
		}

		return interactionsCouter;
	}

	private void consumeInteractions(
		List<fflib_IMatcher> matchers,
		fflib_QualifiedMethod qualifiedMethod,
		fflib_MethodArgValues methodArg)
	{
		Integer lastInteracionIndex = 0;

		//going all through the orderedMethodCalls to find all the interaction of the method
		for (Integer i = idxMethodCall, len = fflib_MethodCountRecorder.getOrderedMethodCalls().size(); i<len; i++)
		{
			fflib_InvocationOnMock invocation = fflib_MethodCountRecorder.getOrderedMethodCalls().get(i);
			for (Object mockInstance : unorderedMockInstances)
			{
				if (invocation.getMock() === mockInstance
					&& (qualifiedMethod == invocation.getMethod())
					&& (argumentsMatch(invocation.getMethodArgValues(), matchers, methodArg)))
				{
					//it's our method
					lastInteracionIndex = i;
					if (matchers != null)
					{
						capture(matchers);
					}
				}
			}
		}

		//now we can move the index to our last call
		idxMethodCall = lastInteracionIndex + 1;
	}

	private Boolean argumentsMatch(
		fflib_MethodArgValues calledMethodArg,
		List<fflib_IMatcher> matchers,
		fflib_MethodArgValues methodArg)
	{
		//Check it was called with the right args.
		if (matchers != null)
		{
			if(fflib_Match.matchesAllArgs(calledMethodArg, matchers))
			{
				//Return now we've matched the method call
				return true;
			}
		}
		else if(calledMethodArg == methodArg)
		{
			//Return now we've matched the method call
			return true;
		}

		return false;
	}

	private fflib_InvocationOnMock getNextMethodCall()
	{
			return getNextMethodCall(true);
	}

	private fflib_InvocationOnMock getNextMethodCall(Boolean updateIdxMethodCall)
	{
		Integer idx = 0;
		for (fflib_InvocationOnMock invocation : fflib_MethodCountRecorder.getOrderedMethodCalls())
		{
			if (idx == idxMethodCall)
			{
				if(isForMockInstance(invocation))
				{
					if(updateIdxMethodCall)
						idxMethodCall++;
					return invocation;
				}
			}
			else
			{
				idx++;
			}
		}

		return null;
	}

	private Boolean isForMockInstance(fflib_InvocationOnMock invocation)
	{
		for (Object mi : unorderedMockInstances)
		{
			if (mi === invocation.getMock())
			{
				return true;
			}
		}

		return false;
	}

	/*
	 * Used by the fflib_InOrder invocation verifier to find further interactions with a given mock instances.
	 * @param mockInstances The tracked mock instances - only methods called on these objects are counted as an invocation.
	 * @param idxLastMethodCalled The index of the last matched method, used to offset the search for invocations so we don't double count invocations.
	 * @return Whether or not there were further interactions.
	 */
	private Boolean hasNextInteraction(List<Object> mockInstances, Integer idxLastMethodCalled)
	{
		Integer idx = 0;

		for (fflib_InvocationOnMock methodCall : fflib_MethodCountRecorder.getOrderedMethodCalls())
		{
			if (isForMockInstance(methodCall))
			{
				idx++;
				if (idx > idxLastMethodCalled)
				{
					return true;
				}
			}
		}

		return false;
	}

	/*
	 * Method that validate the verification mode used in the verify.
	 * Not all the methods from the fflib_VerificationMode are implemented for the different classes that extends the fflib_MethodVerifier.
	 * The error is thrown at run time, so this method is called in the method that actually performs the verify.
	 * @param verificationMode The verification mode that have to been verified.
	 * @throws Exception with message for the fflib_VerificationMode not implemented.
	 */
	protected override void validateMode(fflib_VerificationMode verificationMode)
	{
		if(notImplementedMethods.contains(verificationMode.Method))
		{
			throw new fflib_ApexMocks.ApexMocksException(
				'The ' + verificationMode.Method.name() + ' method is not implemented for the fflib_InOrder class');
		}
	}
}