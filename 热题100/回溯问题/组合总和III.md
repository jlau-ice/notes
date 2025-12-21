
理解之后一边过。
什么时候有startIndex 什么时候需要传入startIndex + 1 ，什么时候传入的是 i + 1 。


```java
class Solution {
    List<Integer> list = new ArrayList<>();
    List<List<Integer>> res = new ArrayList<>();
    public List<List<Integer>> combinationSum3(int k, int n) {
        btr(k, n, 0, 1);
        return res;
    }

    private void btr(int k, int n, int sum, int startIndex) {
        if (sum == n && list.size() == k) {
            res.add(new ArrayList<>(list));
            return;
        }
        for (int i = startIndex; i < 10; i++) {
            list.add(i);
            btr(k, n, sum + i, i + 1);
            list.remove(list.size() - 1);
        }

    }
}
```
