import java.util.LinkedList;
import java.util.List;

public class Queue<T>
{
	private List<T> list = new LinkedList<T>();
	public Queue()
	{
		
	}
	public void push(T t)
	{
		synchronized(list)
		{
			list.add(t);
		}
	}
	public void pop()
	{
		synchronized(list)
		{
			if (!list.isEmpty())
			{
				list.remove(list.size() - 1);
			}
		}
	}
	public synchronized T top()
	{
		return list.get(list.size() - 1);
	}
	public int size()
	{
		return list.size();
	}
}
