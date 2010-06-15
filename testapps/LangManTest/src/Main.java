
public class Main
{
	private static enum Trace 
	{ 
		LEVEL_TRACE(0), LEVEL_DEBUG(1), LEVEL_ERROR(2);
		private int level;
		Trace(int L)
		{
			level = L;
		}
		public int toInt()
		{
			return level;
		}
	};
	private static Trace trace = Trace.LEVEL_TRACE;
	private static void out(String message)	{		log(trace, message);	}
	private static void log(Trace traceLevel, String message)
	{
		if (traceLevel.compareTo(trace) >= 0)
		{
	        String threadName = Thread.currentThread().getName();
	        System.out.format("%s: %s%n", threadName, message);
		}
    }

	private static abstract class RunnableProcessor implements Runnable
	{
		private final int delay;
		public RunnableProcessor(int interval)
		{
			delay = interval;
		}

		public void run()
		{
			try
			{
				while(true)
				{
					Thread.sleep((long)(delay * Math.random()));
					process();
				}
			}
			catch (InterruptedException e)
			{
				
			}
		}
		
		protected abstract void process();
	}

//	private static class Consumer extends RunnableProcessor
//	{
//		private Queue<String> queue;
//		public Consumer(Queue<String> q)
//		{
//			super(5000);
//			queue = q;
//		}
//		protected void process()
//		{
//			
//		}
//	}

	private static class Producer extends RunnableProcessor
	{
		private Queue<String> queue;
		public Producer(Queue<String> q)
		{
			super(50);
			queue = q;
		}
		
		private static final String[] items =
		{
			"Satch Boogie", "Surfing with the Alien", "Time", "Rubina", "Friends"
		};
		protected void process()
		{
			queue.push(items[ (int)(Math.random() * items.length) ]);
		}
	}

	/**
	 * @param args
	 * @throws InterruptedException 
	 */
	public static void main(String[] args) throws InterruptedException
	{
		LangManagementServer lms = new LangManagementServer(2112);
		Thread lmsThread = new Thread(lms);
		lmsThread.start();
		
		Queue<String> queue = new Queue<String>();

		Thread t = new Thread(new Producer(queue));
		t.start();

		// fake producing a bunch of stuff
		new Thread(new Producer(queue)).start();
		new Thread(new Producer(queue)).start();
		new Thread(new Producer(queue)).start();

		while (t.isAlive())
		{
			out("main doing stuff");
			try
			{
				Thread.sleep(5000);
				out("queue contains " + queue.size() + " items");
				
				while(queue.size() > 0)
				{
					queue.pop();
				}
			}
			catch (InterruptedException e)
			{
				
			}
		}
		lmsThread.join();
	}
	
//	private int sum(int... args)
//	{
//		int retval = 0;
//		for (int i : args)
//		{
//			retval += i;
//		}
//		return retval;
//	}
}
