package site.wenyou.app

import java.io.IOException
import java.io.InputStream
import java.io.OutputStream

internal class AudioCopyCancelled : IOException()
internal class AudioCopyTooLarge : IOException()
internal class AudioCopyEmpty : IOException()

/** 对未知长度的文档也执行实际字节预算，不依赖提供者声明的大小。 */
internal object BoundedAudioCopy {
    fun copy(
        input: InputStream,
        output: OutputStream,
        maximumBytes: Long,
        cancelled: () -> Boolean,
    ): Long {
        require(maximumBytes > 0 && maximumBytes < Long.MAX_VALUE)
        val buffer = ByteArray(64 * 1024)
        var count = 0L
        while (true) {
            if (cancelled() || Thread.currentThread().isInterrupted) throw AudioCopyCancelled()
            // 最多多读一个字节即可判断超限，超出的数据不写入磁盘。
            val budget = minOf(buffer.size.toLong(), maximumBytes - count + 1).toInt()
            val read = input.read(buffer, 0, budget)
            if (cancelled() || Thread.currentThread().isInterrupted) throw AudioCopyCancelled()
            if (read < 0) break
            if (read == 0) continue
            count += read
            if (count > maximumBytes) throw AudioCopyTooLarge()
            output.write(buffer, 0, read)
        }
        if (count == 0L) throw AudioCopyEmpty()
        output.flush()
        return count
    }
}
