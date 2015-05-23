public with sharing class Utilities {
	/**
	 * Get the namespace of this package
	 **/
	public static String namespace()
	{
		Schema.DescribeSObjectResult describe = LookupRollupSummary__c.sObjectType.getDescribe();
		String name = describe.getName();
		String localName = describe.getLocalName();
		String namespace = name.removeEnd(localName).removeEnd('__');
		return namespace;
	}

	/**
	 * Get the component prefix based on the current namespace
	 **/
	public static String componentPrefix()
	{
		String namespace = namespace();
		return String.isEmpty(namespace) ? '' : (namespace + '_');
	}

	/**
	 * Get the class prefix based on the current namespace
	 **/
	public static String classPrefix()
	{
		String namespace = namespace();
		return String.isEmpty(namespace) ? '' : (namespace + '.');
	}

	/**
	 * Get the object prefix based on the current namespace
	 **/
	public static String objectPrefix()
	{
		String namespace = namespace();
		return String.isEmpty(namespace) ? '' : (namespace + '__');
	}
}
