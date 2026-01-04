[题目地址](https://leetcode.cn/problems/coin-change-ii/)

这是完全背包问题，但dp 的含义不一样，求的是凑出的方法有多少种。

```java
class Solution {
    public int change(int amount, int[] coins) {
        // dp[i] 表示金额 i 凑出的数量。
        int[] dp = new int[amount + 1];
        dp[0] = 1;
        for (int i = 0; i < coins.length; i++) {
            for (int j = 1; j <= amount; j++) {
                if (j >= coins[i]) {
                    dp[j] += dp[j - coins[i]];
                }
            }
        }
        return dp[amount];
    }
}
```