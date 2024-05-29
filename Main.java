public class Main {
    public static void main(String[] args) {
        for (int i = 0; i < 20_000; i++) {
            add(42, 42);
        }
    }

    private static int add(int a, int b) {
        return a + b;
    }
}

