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
public with sharing class fflib_QualifiedMethod
{
	private String typeName;
	private String methodName;
	private List<Type> methodArgTypes;
	
	public fflib_QualifiedMethod(String typeName, String methodName, List<Type> methodArgTypes)
	{
		this.typeName = typeName;
		this.methodName = methodName;
		this.methodArgTypes = methodArgTypes;	
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
		
		fflib_QualifiedMethod that = other instanceof fflib_QualifiedMethod ? (fflib_QualifiedMethod)other : null;
		
		return that != null
			&& this.typeName == that.typeName
			&& this.methodName == that.methodName
			&& this.methodArgTypes == that.methodArgTypes;
	}
	
	/**
	 * Standard hashCode override.
	 * @return Integer The generated hashCode
	 */
	public Integer hashCode()
	{
		Integer prime = 31;
		Integer result = 1;
		
		result = prime * result + ((methodArgTypes == null) ? 0 : methodArgTypes.hashCode());
		result = prime * result + ((methodName == null) ? 0 : methodName.hashCode());
		result = prime * result + ((typeName == null) ? 0 : typeName.hashCode());
		
		return result;
	}
	
	/**
	 * Standard toString override.
	 * @return String The human friendly description of the method.
	 */
	public override String toString()
	{
		return typeName + '.' + methodName + methodArgTypes;
	}
}