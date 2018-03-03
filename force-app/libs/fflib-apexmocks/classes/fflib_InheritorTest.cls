/*
 * Copyright (c) 2017 FinancialForce.com, inc.  All rights reserved.
 */
@isTest
public class fflib_InheritorTest
{
 	@isTest
    public static void canInstantiateMultipleInterfaceInheritor()
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Object inheritor = mocks.mock(fflib_Inheritor.class);
        System.assert(inheritor instanceof fflib_Inheritor.IA);
        System.assert(inheritor instanceof fflib_Inheritor.IB);
        System.assert(inheritor instanceof fflib_Inheritor.IC);
    }

 	@isTest
    public static void canStubMultipleInterfaceInheritor()
    {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_Inheritor inheritor = (fflib_Inheritor)mocks.mock(fflib_Inheritor.class);

        mocks.startStubbing();
        mocks.when(inheritor.doA()).thenReturn('Did not do A');
        mocks.when(inheritor.doB()).thenReturn('Did not do B');
        mocks.when(inheritor.doC()).thenReturn('Did not do C');
        mocks.stopStubbing();
        
        System.assertEquals('Did not do A', inheritor.doA());
        System.assertEquals('Did not do B', inheritor.doB());
        System.assertEquals('Did not do C', inheritor.doC());
    }
}