/**
 * Copyright (c), Andrew Fawcett
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the Andrew Fawcett, nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

/**
 * Generic exception class used by methods on the RollupService
 **/
public class RollupServiceException extends Exception 
{
	/**
	 * Generic exception when aspects of the rollup summary definition are found to be in error at runtime
	 **/
	public static RollupServiceException invalidRollup(RollupSummary lookup, String configInvalid)
	{ 
		return new RollupServiceException('Lookup Rollup Summary  \'' + lookup.Name + '\' is invalid, your org configuration may have changed (' + configInvalid + ').');
	}
	
	/**
	 * Unable to find the given lookup
	 **/
	public static RollupServiceException rollupNotFound(Id lookupId)
	{
		return new RollupServiceException('Invalid rollup ' + lookupId + ' not found.');
	}
	
	/**
	 * Job alraedy executed to recalculate rollup 
	 **/
	public static RollupServiceException jobAlreadyRunning(String name)
	{
		return new RollupServiceException('A calculate job for rollup \'' + name + '\' is already executing. If you suspect it is not aleady running try clearing the applicable record from the Lookup Rollup Calculate Jobs tab and try again.');
	}
	
	/**
	 * Jobs executing
	 **/
	public static RollupServiceException jobsExecuting(String className)
	{
		return new RollupServiceException('A previous Declarative Rollup Summary scheduled job \'' + className + '\' is still running, this scheduled execution will not occur.');
	}
}