[题目地址](https://leetcode.cn/problems/last-stone-weight-ii/description/)

这题理解的清楚转化为背包问题就很简单了。

转化为往背包容量为 sum/2 里面装最重的物品。
我已开始还在想这个背包可以越界一点啊。但是又一想不对，这部分越了，另外一一部分不就是互补吗？
所以找不越界的最大 即可
最后的结果就是消除这部分 另外大部分减去这小部分 就是剩下的，如果相等最好就不会有剩下的了。

```java
class Solution {
    public int lastStoneWeightII(int[] stones) {
        int sum = 0;
        for (int i = 0; i < stones.length; i++) {
            sum += stones[i];
        }
        int c = sum / 2;
        int[] dp = new int[c + 1];
        // 转化为背包问题，背包的容量为c, 物品的重量 价值都是一样的，如何装最大价值的物品
        for (int i = 1; i <= stones.length; i++) {
            for (int j = c; j > 0; j--) {
                if (j >= stones[i - 1]) {
                    dp[j] = Math.max(dp[j - stones[i - 1]] + stones[i - 1], dp[j]);
                }
            }
        }
        return sum - 2 * (dp[c]);
    }
}
```
