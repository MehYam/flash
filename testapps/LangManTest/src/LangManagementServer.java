import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import java.lang.management.ClassLoadingMXBean;
import java.lang.management.CompilationMXBean;
import java.lang.management.GarbageCollectorMXBean;
import java.lang.management.ManagementFactory;
import java.lang.management.MemoryMXBean;
import java.lang.management.MemoryManagerMXBean;
import java.lang.management.OperatingSystemMXBean;
import java.lang.management.RuntimeMXBean;
import java.lang.management.ThreadInfo;
import java.lang.management.ThreadMXBean;

public class LangManagementServer implements Runnable
{
	private final int port;
	public LangManagementServer(int port)
	{
		this.port = port;
	}

	private static void log(String message)
	{
		System.out.println("LMS: " + message);
    }

	private static class LangManagementStatsCollector
	{
		private static <T> String join(T[] tees, String separator)
		{
			StringBuilder retval = new StringBuilder("");
			
			for (T t: tees)
			{
				if (retval.length() != 0) 
				{
					retval.append(separator);
				}
				retval.append(t);
			}
			return retval.toString();
		}
		private static String join(long[] tees, String separator)
		{
			StringBuilder retval = new StringBuilder("");
			for (long t : tees)
			{
				if (retval.length() != 0) 
				{
					retval.append(separator);
				}
				retval.append(t);
			}
			return retval.toString();
		}

		private StringBuilder result = new StringBuilder();
		private void addLn(String str) 
		{
			result.append(str + "\n\r");
		}
		
		public void collectAll()
		{
			collectCompilationStats();
			collectClassLoadingStats();
			collectMemoryStats();
			collectOSStats();
			collectRuntimeStats();
			collectGarbageCollectorStats();
			collectMemoryManagerStats();
			collectMemoryStats();
			collectThreadStats();
		}
		
		public void collectCompilationStats()
		{
			CompilationMXBean cmpBean = ManagementFactory.getCompilationMXBean();
			
			addLn("Compilation:");
			addLn("  name: " + cmpBean.getName());
			addLn("  compilation time supported: " + cmpBean.isCompilationTimeMonitoringSupported());
			addLn("  compilation time: " + cmpBean.getTotalCompilationTime());
		}
		
		public void collectClassLoadingStats()
		{
			ClassLoadingMXBean clBean = ManagementFactory.getClassLoadingMXBean();

			addLn("ClassLoading:");
			addLn("  verbose: " + clBean.isVerbose());
			addLn("  loaded count: " + clBean.getLoadedClassCount());
			addLn("  total loaded count: " + clBean.getTotalLoadedClassCount());
		}
		
		public void collectMemoryStats()
		{
			MemoryMXBean mem = ManagementFactory.getMemoryMXBean();
			mem.setVerbose(true);

			addLn("Memory:");
			addLn("  verbose: " + mem.isVerbose());
			addLn("  heap: " + mem.getHeapMemoryUsage());
			addLn("  non heap: " + mem.getNonHeapMemoryUsage());
			addLn("  pending finalization: " + mem.getObjectPendingFinalizationCount());
		}
		
		public void collectOSStats()
		{
			OperatingSystemMXBean os = ManagementFactory.getOperatingSystemMXBean();

			addLn("OperatingSystem:");
			addLn("  name: " + os.getName());
			addLn("  version: " + os.getVersion());
			addLn("  arch: " + os.getArch());
			addLn("  cpus: " + os.getAvailableProcessors());
			addLn("  load: " + os.getSystemLoadAverage());
		}
		
		public void collectRuntimeStats()
		{
			RuntimeMXBean runtime = ManagementFactory.getRuntimeMXBean();
			
			addLn("Runtime:");
			addLn("  uptime: " + runtime.getUptime());
			addLn("  name: " + runtime.getName());
			addLn("  vm name: " + runtime.getVmName());
			addLn("  vm vendor: " + runtime.getVmVendor());
			addLn("  vm version: " + runtime.getVmVersion());
			addLn("  spec name: " + runtime.getSpecName());
			addLn("  spec vendor: " + runtime.getSpecVendor());
			addLn("  spec version: " + runtime.getSpecVersion());
			addLn("  mgmt version: " + runtime.getManagementSpecVersion());
			addLn("  boot classpath: " + runtime.getBootClassPath());
			addLn("  classpath: " + runtime.getClassPath());
			addLn("  lib path: " + runtime.getLibraryPath());
			addLn("  start time: " + runtime.getStartTime());

			addLn("  system properties: ");
			Map<String, String> map = runtime.getSystemProperties();
			Set<String> sorted = new TreeSet<String>(map.keySet());

			for (String key : sorted)
			{
				addLn("     " + key + ": " + map.get(key));
			}
			
			addLn("  input arguments: ");
			List<String> args = runtime.getInputArguments();
			for (String arg : args)
			{
				addLn("     " + arg);
			}
		}
		
		public void collectGarbageCollectorStats()
		{
			List<GarbageCollectorMXBean> beans = ManagementFactory.getGarbageCollectorMXBeans();
			addLn("GarbageCollectors:");
			for (GarbageCollectorMXBean bean : beans)
			{
				addLn("  name: " + bean.getName());
				addLn("  collection count: " + bean.getCollectionCount());
				addLn("  collection time: " + bean.getCollectionTime());
				addLn("  memory pool names: " + join(bean.getMemoryPoolNames(), ","));
			}
			
		}

		public void collectMemoryManagerStats()
		{
			List<MemoryManagerMXBean> memoryManagers = ManagementFactory.getMemoryManagerMXBeans();
			addLn("MemoryManagers:");
			for (MemoryManagerMXBean mm : memoryManagers)
			{
				addLn("  name: " + mm.getName());
				addLn("  pool names: " + join(mm.getMemoryPoolNames(), ","));
			}
		}

		public void collectThreadStats()
		{
			ThreadMXBean threadBean = ManagementFactory.getThreadMXBean();

			addLn("Threads:");
			addLn("  count: " + threadBean.getThreadCount());
			addLn("  peakCount: " + threadBean.getPeakThreadCount());
			addLn("  monitorUsageSupported: " + threadBean.isObjectMonitorUsageSupported());
			addLn("  synchronizerUsageSupported: " + threadBean.isSynchronizerUsageSupported());
			addLn("  contentionMonitoringSupported: " + threadBean.isThreadContentionMonitoringSupported());
			addLn("  contentionMonitoringEnabled: " + threadBean.isThreadContentionMonitoringEnabled());

			long[] threadIDs = threadBean.findDeadlockedThreads();
			if (threadIDs != null && threadIDs.length > 0)
			{
				addLn("  deadlocked: " + join(threadIDs, ","));
			}
			threadIDs = threadBean.findMonitorDeadlockedThreads();
			if (threadIDs != null && threadIDs.length > 0)
			{
				addLn("  monitorDeadlocked: " + join(threadIDs, ","));
			}

			ThreadInfo[] threads = threadBean.dumpAllThreads(true, true);
			for (ThreadInfo thread : threads)
			{
				addLn("--thread: " + thread.getThreadId() + ", " + thread.getThreadName());
				addLn("  state: " + thread.getThreadState());
				addLn("  suspended: " + thread.isSuspended());
				addLn("  blockedCount: " + thread.getBlockedCount());
				addLn("  blockedTime: " + thread.getBlockedTime());
				addLn("  waitedCount: " + thread.getWaitedCount());
				addLn("  waitedTime: " + thread.getWaitedTime());
				addLn("  isInNative: " + thread.isInNative());
				if (thread.isSuspended())
				{
					addLn("  lock: " + thread.getLockOwnerId() + ", " + thread.getLockName() + ", " + thread.getLockOwnerName());
				}
				addLn("  stack:");

				StackTraceElement[] frames = thread.getStackTrace();
				for (StackTraceElement frame : frames)
				{
					addLn("    " + frame.getClassName() + "." + frame.getMethodName() + "  " + frame.getFileName() + ":" + frame.getLineNumber());
				}
			}
		}
		
		public String toString()
		{
			return result.toString();
		}
	}

	private static String processCommand(String command)
	{
		LangManagementStatsCollector collector = new LangManagementStatsCollector();
		if (command.equalsIgnoreCase("all"))
		{
			collector.collectAll();
		}
		else if (command.equalsIgnoreCase("compilation"))
		{
			collector.collectCompilationStats();
		}
		else if (command.equalsIgnoreCase("classLoading"))
		{
			collector.collectClassLoadingStats();
		}
		else if (command.equalsIgnoreCase("memory"))
		{
			collector.collectMemoryStats();
		}
		else if (command.equalsIgnoreCase("os"))
		{
			collector.collectOSStats();
		}
		else if (command.equalsIgnoreCase("runtime"))
		{
			collector.collectRuntimeStats();
		}
		else if (command.equalsIgnoreCase("gc"))
		{
			collector.collectGarbageCollectorStats();
		}
		else if (command.equalsIgnoreCase("memoryManager"))
		{
			collector.collectMemoryManagerStats();
		}
		else if (command.equalsIgnoreCase("memory"))
		{
			collector.collectMemoryStats();
		}
		else if (command.equalsIgnoreCase("thread"))
		{
			collector.collectThreadStats();
		}

		return collector.toString();
	}

	private ServerSocket listener = null;
	private Boolean terminate = false;
	public void quit()
	{
		terminate = true;
		if (listener != null)
		{
			try
			{
				log("closing listener");
				listener.close();
			}
			catch (IOException e)
			{
			    log("socket read failure in quit()");
			}
		}
	}
	public void run()
	{
		while(!terminate)  //KAI: needs graceful interruptability
		{
			listener = null;
			try
			{
				listener = new ServerSocket(port);
				log("listening");
			}
			catch (IOException e)
			{
				log("could not listen on port " + port);
			}
				
			Socket client = null;
			try
			{
			    client = listener.accept();
			    log("accepted connection");
				BufferedReader clientReader = new BufferedReader(new InputStreamReader(client.getInputStream()));
				
				final String commands = clientReader.readLine();
				log("read line");
				PrintWriter clientWriter = new PrintWriter(client.getOutputStream(), true);
				clientWriter.println("Result for: " + commands);

				String[] commandArray = commands.split("\\s+");
				for (String command : commandArray)
				{
						clientWriter.println(processCommand(command));
				}

				clientWriter.close();
				clientReader.close();
				
				client.close();
				listener.close();
			}
			catch (IOException e)
			{
			    log("socket read failure");
			}
		}
	}
}
