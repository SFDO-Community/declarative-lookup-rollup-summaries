/*
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

/**
 * @group Core
 * Class defining a method return value.
 */
@isTest
public with sharing class fflib_MethodReturnValue
{
	/**
	 * Instance of the implementation of the Answer interface that implements the answer,
	 * if an answer isn't explicitly set the standard answer will be used, which just returns the stubbed return value.
	 */
	public fflib_Answer Answer { get; set; }

	/**
	 * Setup a stubbed return value.
	 * @param value The value to return from the stubbed method call.
	 */
	public void thenReturn(Object value)
	{
		thenAnswer(new StandardAnswer(value));
	}

	/**
	 * Setup a stubbed exception.
	 * @param e The exception to throw from the stubbed method call.
	 */
	public void thenThrow(Exception e)
	{
		thenAnswer(new StandardAnswer(e));
	}

	/**
	 * Setup a stubbed answer.
	 * @param answer The answer to run from the stubbed method call.
	 */
	public void thenAnswer(fflib_Answer answer)
	{
		this.Answer = answer;
	}

	/**
	 * @group Core
	 * Inner class to handle all the stubs that do not use the thenAnswer method directly.
	 * For internal use only.
	 */
	public class StandardAnswer implements fflib_Answer
	{
		/**
		 * It stores the return value for the method stubbed.
		 * The value would be stored and then returned as part of the standard answer invocation.
		 */
		public Object ReturnValue { get; set; }

		/**
		 * Constructor for the StandardAnswer object.
		 * @param value The value to be set as return value for the StandardAnswer object.
		 */
		public StandardAnswer(Object value)
		{
			ReturnValue = value;
		}

		/**
		 * Standard basic implementation for the fflib_Answer answer method, to be used as default answering.
		 * @param invocation The invocation to answer for.
		 * @return The ReturnValue for the method stubbed.
		 */
		public Object answer(fflib_InvocationOnMock invocation)
		{
			return ReturnValue;
		}
	}
}