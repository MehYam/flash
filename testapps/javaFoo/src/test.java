import java.sql.Time;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;


public class test
{

	public static void log(String str)
	{
		System.out.println(str);
	}

	/**
	 * @param args
	 */
	public static void main(String[] args)
	{
		log("hey man");
		
		testContainers();
		testTime();
		testGenerics();
	}
	
	private static void testContainers()
	{
		Map<String, String> map = new HashMap<String, String>();
		
		map.put("D", "Damage");
		map.put("H", "Health");
		map.put("S", "Stamina");
		map.put("R", "Ring");

		log(map.toString());

		Set<String> setAll = new HashSet<String>(map.keySet());
		log(setAll.toString());
		
		Set<String> incl = new HashSet<String>();
		incl.add("S");
		incl.add("R");
		
		Set<String> excl = new HashSet<String>(setAll);
		
		log(excl.toString());
		
		excl.removeAll(incl);
		
		log("minus " + incl.toString() + " equals " + excl.toString());
		
		Set<String> values = new HashSet<String>(map.values());
		
		log("reversed: " + values.toString());

		Set<String> keySet = map.keySet();
		
		keySet.removeAll(excl);
		
		log("map minus " + excl.toString() + " equals " + map.toString());
		
		for (String str : keySet)
		{
			log(str);
		}
	}
	
	private static class StopWatch
	{
		public StopWatch() {}

		private static SimpleDateFormat df = new SimpleDateFormat("HH:mm:ss");
		private long startTime = 0;
		public void setTime(String time)
		{
			try
			{
				startTime = df.parse(time).getTime();
				log("ms " + Long.toString(df.parse(time).getTime()));
				log("" + startTime);
			}
			catch (ParseException pe)
			{
				// swallow it, for now
			}
		}
		
		private long timeStarted = 0;
		private boolean playing = false; 
		public void start()
		{
			playing = true;
			timeStarted = System.currentTimeMillis();
		}
		
		private long timeElapsed = 0; 
		public void stop()
		{
			playing = false;
			final long now = System.currentTimeMillis();
			
			timeElapsed = now - timeStarted;  
		}

		public String elapsed()
		{
			return df.format(timeElapsed + startTime);
		}
	}
	
	private static void testTime()
	{
		
		StopWatch sw = new StopWatch();
		
		sw.setTime("5:30:00");
		sw.start();
		
		try {
			Thread.sleep(2112);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}

		sw.stop();
		
		log(sw.elapsed());
	}
	
	private static void testGenerics()
	{
		GenericsTest t = new GenericsTest();
		t.run();
	}
}
