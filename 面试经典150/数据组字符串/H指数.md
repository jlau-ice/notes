

这题一般的思路就是排寻后遍历，找出最大的
这是排序后遍历的解法
```java
class Solution {
    public int hIndex(int[] citations) {
        Arrays.sort(citations);
        for (int i = 0, j = citations.length - 1; i < j; i++, j--) {
            int temp = citations[i];
            citations[i] = citations[j];
            citations[j] = temp;
        }
        int res = 0;
        for (int i = 0; i < citations.length; i++) {
            if (citations[i] >= i + 1) {
                res++;
            } else {
                break;
            }
        }
        return res;
    }
}
```
这是利用一个桶去找出最大的i。
```java
class Solution {
    public int hIndex(int[] citations) {
        int[] bucket = new int[citations.length + 1];
        for (int c : citations) {
            if (c >= citations.length) {
                bucket[citations.length]++;
            } else {
                bucket[c]++;
            }
        }

        int h = 0;
        for (int i = bucket.length - 1; i >= 0; i--) {
            h += bucket[i];
            if (h >= i) {
                return i;
            }
        }
        return 0;
    }
}
```