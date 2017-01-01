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
 * 	This class implements the capturing framework for ApexMocks
 *	According to Mockito's syntax the type is passed in the capturer construction,
 *	however Apex cannot perform the auto casting that Java can.
 *	To be consistent with Mockito, the capturer does not perform any checks on the type of the argument.
 * 	@group Core
 */
public with sharing class fflib_ArgumentCaptor
{
	protected List<Object> argumentsCaptured = new List<Object>();

	/**
	 *	Factory method to create a new fflib_ArgumentCaptor.
	 * 	Takes the captured argument's Type for consistency with Mockito syntax.
	 * 	The Type is IGNORED because we can't determine an object instance's Type at runtime unlike in Java.
	 *	Rigorous type checking may be introduced in a future release, so you should specify the expected argument type correctly.
	 *
	 * 	@param 	ignoredCaptureType Type (class) of the captured argument
	 * 	@return A new fflib_ArgumentCaptor.
	 */
	public static fflib_ArgumentCaptor forClass(Type ignoredCaptureType)
	{
		return new fflib_ArgumentCaptor();
	}

	/**
	 *	Use it to capture the argument. This method must be used inside verification.
	 *	Internally, this method registers a special implementation of a Matcher.
	 * 	This argument matcher stores the argument value so that you can use it later to perform assertions.
	 *
	 * 	@return a special matcher that matches any argument and remembers the value.
	 */
	public Object capture()
	{
		AnyObject myMatcher = new AnyObject(this);

		return fflib_Match.matches(myMatcher);
	}

	/**
	 *	Returns the captured value of the argument. When capturing all arguments use getAllValues().
	 *	If verified method was called multiple times then this method returns the latest captured value.
	 *
	 * 	@return	captured argument value.
	 */
	public Object getValue()
	{
		if( argumentsCaptured == null ||
			argumentsCaptured.size() == 0)
		{
			return null;
		}

		//returns the last argument called
		return argumentsCaptured.get( argumentsCaptured.size() - 1 );
	}

	/**
	 *	Returns all captured values. Use it when capturing multiple arguments or when the verified method was called multiple times.
	 *	When capturing multiple arguments is called multiple times, this method returns a merged list of all values from all invocations.
	 *
	 * 	@return	Returns all captured values. Use it when capturing multiple arguments on the same call or when the verified method was called multiple times.
	 */
	public List<Object> getAllValues()
	{
		return argumentsCaptured;
	}

	public class AnyObject implements fflib_IMatcher
	{
		private fflib_ArgumentCaptor captor;
		private Object value;

		public AnyObject(fflib_ArgumentCaptor captor)
		{
			this.captor = captor;
		}

		//match with all the possible values and store the arg value
		public Boolean matches(Object arg)
		{
			value = arg;
			return true;
		}

		//store the argument in the list ( this would be called inside the method counter where is compared with the matchers of the method)
		public void storeArgument()
		{
			captor.argumentsCaptured.add(value);
		}
	}
}