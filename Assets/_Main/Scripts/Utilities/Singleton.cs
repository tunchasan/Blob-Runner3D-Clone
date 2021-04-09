using UnityEngine;

public class Singleton<T> : MonoBehaviour where T : MonoBehaviour
{
    private static object _lock = new object();
    private static T _instance;

    public static T Instance
    {
        get
        {
            lock (_lock)
            {
                if (_instance == null) _instance = (T) FindObjectOfType(typeof(T));

                return _instance;
            }
        }
    }
}