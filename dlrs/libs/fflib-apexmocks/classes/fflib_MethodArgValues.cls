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
public with sharing class fflib_MethodArgValues
{
	public List<Object> argValues;
	
	/**
	 * Wrapper object which encapsulates the argument values
	 * supplied during a given method call.
	 * @param argValues The
	 * @return fflib_MethodArgValues The method argument wrapper object
	 */
	public fflib_MethodArgValues(List<Object> argValues)
	{
		this.argValues = argValues;
	}
	
	/**
	 * Standard equals override.
	 * @param other The object whose equality we are verifying
	 * @return Boolean True if meaningfully equivalent, false otherwise.
	 */
	public Boolean equals(Object other)
	{
		if (this === other)
		{
			return true;
		}
		
		fflib_MethodArgValues that = other instanceof fflib_MethodArgValues ? (fflib_MethodArgValues)other : null;
		return that != null && this.argValues == that.argValues;
	}
	
	/**
	 * Standard hashCode override.
	 * @return Integer The generated hashCode
	 */
	public Integer hashCode()
	{
		Integer prime = 31;
		Integer result = 1;
		
		result = prime * result + ((argValues == null) ? 0 : argValues.hashCode());
		
		return result;
	}
}