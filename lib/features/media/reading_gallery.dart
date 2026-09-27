/// 阅读入口使用的图集公开门面；业务动作由调用方按当前图片来源绑定。
library;

export 'domain/reading_image_gallery.dart'
    show ReadingGalleryImage, ReadingGalleryOrder, ReadingGalleryScope;
export 'presentation/reading_image_gallery_page.dart'
    show ReadingGalleryTarget, openReadingImageGallery;
