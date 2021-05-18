import java.util.UUID;
import java.util.concurrent.locks.LockSupport;

// https://imshuai.com/using-javac
// javac StringInterner.java
// java StringInterner

public class StringInterner {

    public static volatile String lastString;

    public static void main(String[] args) {
        for ( int iterations = 0;;  ) {
            String baseName = UUID.randomUUID().toString();
            for (int i = 0; i < 1_000_000; i++) {
                lastString = (baseName + i).intern();
            }
            if (++iterations % 10 == 0) {
                // memory reclaimed by full gc?
                System.gc();
            }
            LockSupport.parkNanos(500_000_000);
        }
    }
}