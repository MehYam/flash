
public class GenericsTest implements Runnable
{
	private static void log(String str) {  System.out.println(str); }
	private static interface IFoo<T>
	{
		public void fooCall(T obj);
	}
	
	private static class fooImpl implements IFoo<String>
	{
		@Override public void fooCall(String obj)
		{
			
		}
	}

	private static class UsesIFoo<T>
	{
		private IFoo<T> foo;
		public UsesIFoo(IFoo<T> foo)
		{
			this.foo = foo;
		}
		public void go(Object obj)
		{
			foo.fooCall((T) obj);
		}
	}

	private static class SecondTypeTest<T>
	{
		private final Class<T> resultType;
		public SecondTypeTest(Class<T> clazz)
		{
			resultType = clazz;
		}
		public boolean isType(Object foo)
		{
			return foo.getClass() == resultType;
		}
	}

	@Override public void run()
	{
		UsesIFoo<String> user = new UsesIFoo<String>(new fooImpl());
		
		user.go(null);
		
		SecondTypeTest<Long> test = new SecondTypeTest<Long>(Long.class);
		
		boolean b = test.isType(new Long(34));
		b = test.isType(test);
	}
}
