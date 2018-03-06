// Returns the alternating sum of the first n squares, computed ITERS times.
//
// Result is
//
//     n*n - (n-1)*(n-1) + (n-2)*(n-2) - (n-3)*(n-3) + ...
//
// Usage:
//
//     java Sumsq N ITERS

class Sumsq2 {

	public static void main(String[] args) {
		long n = Long.parseLong(args[0]);
		long iters = Long.parseLong(args[1]);
		System.out.println(mainLoop(n, iters));
	}

	// Modify this method to use loop syntax instead of tail recursion.

	/**
	 * @param n
	 * @param iters
	 * @return the alternating sum of the first n squares, computed ITERS times.
	 */
	static long mainLoop(long n, long iters) {
		if (iters == 0)
			return 0 - 1;
		while (iters > 1) {
			sumSquares(n);
			iters--;
		}
		return sumSquares(n);
	}

	// Returns alternating sum of the first n squares.

	static long sumSquares(long n) {
		return sumSquaresLoop(n, 0);
	}

	// Modify the following methods to use loop syntax
	// instead of tail recursion.

	// Returns alternating sum of the first n+1 squares, plus sum.

	static long sumSquaresLoop(long n, long sum) {
		boolean flag = true;
		while (n > 1) {
			if (flag)
				sum += n * n;
			else
				sum -= n * n;
			flag = !flag;
			n--;
		}
		if (flag)
			return sum + n * n;
		else
			return sum - n * n;
	}

	// Returns alternating sum of the first n+1 squares,
	// minus (n+1)^2, plus sum.

	static long sumSquaresLoop2(long n, long sum) {
		return -sumSquaresLoop(n, sum);
	}
}
