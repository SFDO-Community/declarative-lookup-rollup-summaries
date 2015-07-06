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
public with sharing class fflib_MyList implements IList
{
	public interface IList
	{
		void add(String value);
		String get(Integer index);
		String get2(Integer index, String value); // This is just a method signature to allow me to test stubbing a method with multiple arguments
		void clear();
		Boolean isEmpty();
		void set(Integer index, Object value);
	}

	public void add(String value)
	{
	}

	public String get(Integer index)
	{
		return 'fred';
	}

	public void clear()
	{
	}

	public Boolean isEmpty()
	{
		return true;
	}

	public void set(Integer index, Object value)
	{
	}

	public String get2(Integer index, String value)
	{
		return 'mary';
	}
}