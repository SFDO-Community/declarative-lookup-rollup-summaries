@isTest
public class fflib_Mocks
{

	public class Mockfflib_MyList implements fflib_MyList.IList
	{
		private fflib_ApexMocks mocks;

		public Mockfflib_MyList(fflib_ApexMocks mocks)
		{
			this.mocks = mocks;
		}

		public void add(String value)
		{
			mocks.mockVoidMethod(this, 'add', new List<Object> {value});
		}

		public String get(Integer index)
		{
			return (String) mocks.mockNonVoidMethod(this, 'get', new List<Object> {index});
		}

		public String get2(Integer index, String value)
		{
			return (String) mocks.mockNonVoidMethod(this, 'get2', new List<Object> {index, value});
		}

		public void clear()
		{
			mocks.mockVoidMethod(this, 'clear', new List<Object> {});
		}

		public Boolean isEmpty()
		{
			return (Boolean) mocks.mockNonVoidMethod(this, 'isEmpty', new List<Object> {});
		}

		public void set(Integer index, Object value)
		{
			mocks.mockVoidMethod(this, 'set', new List<Object> {index, value});
		}
	}
}