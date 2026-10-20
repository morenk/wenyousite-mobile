package site.wenyou.app

import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.IOException

/** 仅 JVM 运行复制边界，不构建或启动 Android 应用。 */
fun main() {
    val bytes = ByteArray(200000) { (it % 127).toByte() }
    val target = ByteArrayOutputStream()
    check(BoundedAudioCopy.copy(ByteArrayInputStream(bytes), target, bytes.size.toLong()) { false } == bytes.size.toLong())
    check(target.toByteArray().contentEquals(bytes))

    var read = 0
    val bounded = object : ByteArrayInputStream(bytes) {
        override fun read(buffer: ByteArray, offset: Int, length: Int): Int {
            val count = super.read(buffer, offset, length)
            if (count > 0) read += count
            return count
        }
    }
    val oversized = ByteArrayOutputStream()
    expect<AudioCopyTooLarge> { BoundedAudioCopy.copy(bounded, oversized, 100) { false } }
    check(read == 101 && oversized.size() <= 100)
    expect<AudioCopyEmpty> { BoundedAudioCopy.copy(ByteArrayInputStream(byteArrayOf()), target, 100) { false } }
    expect<AudioCopyCancelled> { BoundedAudioCopy.copy(ByteArrayInputStream(bytes), target, 300000) { true } }
    val partial = ByteArrayOutputStream()
    expect<AudioCopyCancelled> { BoundedAudioCopy.copy(ByteArrayInputStream(bytes), partial, 300000) { partial.size() > 0 } }
    check(partial.size() == 64 * 1024)
    val broken = object : ByteArrayInputStream(bytes) {
        override fun read(buffer: ByteArray, offset: Int, length: Int): Int = throw IOException("provider closed")
    }
    expect<IOException> { BoundedAudioCopy.copy(broken, target, 300000) { false } }
    println("BoundedAudioCopy: 6 checks passed")
}

private inline fun <reified T : Throwable> expect(operation: () -> Unit) {
    try { operation(); error("Expected ${T::class.java.simpleName}") }
    catch (error: Throwable) { check(error is T) { "Unexpected ${error::class.java.simpleName}" } }
}
