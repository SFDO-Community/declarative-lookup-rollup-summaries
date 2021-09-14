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
 * Trigger bypass handler class that stores information regarding which rollups are to be ignored in a transaction.
 * The rollups in the specified set attribute are to be ignored by the rollup service.
 *
 * The bypass and removebypass method return the result of the default Set object operations.
 **/
public without sharing class BypassHandler
{
    private static Set<String> bypassedRollups;

    /**
     * Initialize the set if necessary for adding rollups to the bypass list.
     */
    private static void init()
    {
        if (bypassedRollups == null)
        {
            bypassedRollups = new Set<String>();
        }
    }

    /**
     * Checks if the rollup is bypassed or not. Returns true if it is. False otherwise.
     */
    public static Boolean isBypassed(String handlerName)
    {
        return bypassedRollups != null && bypassedRollups.contains(handlerName);
    }

    /**
     * Adds a rollup to the bypassed rollups list.
     */
    public static Boolean bypass(String handlerName)
    {
        init();

        if (handlerName != null)
        {
            System.debug(LoggingLevel.INFO, 'DLRS trigger handler is now bypassed: ' + handlerName);
            return bypassedRollups.add(handlerName);
        }

        System.debug(LoggingLevel.WARN, 'Tried to add a rollup to the bypass list, but its name was null.');

        return false;
    }

    /**
     * Clears the bypass for a single rollup.
     */
    public static Boolean clearBypass(String handlerName)
    {
        if (bypassedRollups != null && handlerName != null)
        {
            System.debug(LoggingLevel.INFO, 'DLRS trigger handler is no longer bypassed: ' + handlerName);
            return bypassedRollups.remove(handlerName);
        }

        System.debug(LoggingLevel.WARN, 'Tried to remove a rollup to the bypass list, but its name was null or it was not on the list at all.');

        return false;
    }

    /**
     * Clears all bypasses, if any.
     */
    public static void clearAllBypasses()
    {
        if (bypassedRollups != null)
        {
            bypassedRollups.clear();
        }
    }
}
