/// بيانات مبادرة «توعية الأطفال عن مخاطر الإنترنت» (CST) للتكامل مع جدول الفيديوهات.
class CstVideoSeed {
  CstVideoSeed._();

  static const List<CstClip> clips = [
    CstClip(
      title: 'التحرش بالأطفال',
      duration: '2:09',
      summary:
          'استعراض أساليب الاستدراج التي يستخدمها المجهولون لبناء علاقات غير آمنة مع الأطفال.',
      behavioralImpact:
          'رسم حدود الخصوصية الجسدية والرقمية، وتمكين الطفل من رفض التواصل المشبوه فوراً.',
      youtubeVideoId: 'JcSKPKJ1iUc',
    ),
    CstClip(
      title: 'الأمور الإباحية',
      duration: '2:29',
      summary:
          'تسليط الضوء على مخاطر المحتوى الهابط الذي يظهر فجأة وكيفية تجنبه.',
      behavioralImpact:
          'حماية النماء النفسي والأخلاقي، وتعزيز مبدأ الرقابة الذاتية عند غياب الرقابة الأبوية.',
      youtubeVideoId: 'UtoVsjrTOPc',
    ),
    CstClip(
      title: 'البرمجيات الخبيثة',
      duration: '2:30',
      summary:
          'شرح تقني مبسط للملفات والروابط التي تستهدف اختراق الأجهزة وسرقة البيانات.',
      behavioralImpact:
          'تعزيز ثقافة النظافة التقنية وحماية الأجهزة من التجسس أو التلف البرمجي.',
      youtubeVideoId: 'CZ9PN1poYxs',
    ),
    CstClip(
      title: 'التعرض لمحتوى غير لائق',
      duration: '2:12',
      summary:
          'معالجة قضية التدفق العشوائي للصور والفيديوهات التي لا تناسب الفئة العمرية للأطفال.',
      behavioralImpact:
          'تطوير مهارات التفكير الناقد والقدرة على فرز المحتوى وتجاهل ما هو غير ملائم.',
      youtubeVideoId: 'ppqhJcWAvIE',
    ),
    CstClip(
      title: 'النصب والاحتيال',
      duration: '2:22',
      summary:
          'كشف أساليب التلاعب الرقمي التي تهدف إلى الحصول على مكاسب مادية أو وهمية.',
      behavioralImpact:
          'غرس الحس الأمني المالي والرقمي، والتشكيك في العروض المغرية والجوائز الوهمية.',
      youtubeVideoId: 'YGSWPzFD3WM',
    ),
    CstClip(
      title: 'استغلال المعلومات الشخصية',
      duration: '2:23',
      summary:
          'التحذير من مخاطر مشاركة البيانات الحساسة (الموقع، أرقام التواصل، الصور الخاصة).',
      behavioralImpact:
          'حماية الهوية الرقمية ومنع استغلال البيانات الشخصية في عمليات الابتزاز أو انتحال الشخصية.',
      youtubeVideoId: 'NLVjlIrc_sA',
    ),
    CstClip(
      title: 'الابتزاز والمضايقة',
      duration: '2:19',
      summary:
          'تحليل الضغوط النفسية التي يمارسها المبتزون ضد الأطفال لإجبارهم على فعل معين.',
      behavioralImpact:
          'كسر حاجز الخوف لدى الطفل وتوجيهه نحو بروتوكولات الإبلاغ وطلب المساعدة فوراً.',
      youtubeVideoId: '03j8iQQNIyU',
    ),
    CstClip(
      title: 'التنمر',
      duration: '2:23',
      summary:
          'تعريف التنمر الإلكتروني وآثاره النفسية والاجتماعية على الضحية والمجتمع الافتراضي.',
      behavioralImpact:
          'بناء شخصية رقمية متزنة، ونشر قيم التسامح مع توضيح آليات المواجهة القانونية والتقنية.',
      youtubeVideoId: 'yTGFQyvijH8',
    ),
  ];
}

class CstClip {
  const CstClip({
    required this.title,
    required this.duration,
    required this.summary,
    required this.behavioralImpact,
    required this.youtubeVideoId,
  });

  final String title;
  final String duration;
  final String summary;
  final String behavioralImpact;
  final String youtubeVideoId;

  String get description =>
      '[المدة تقريبياً: $duration]\n\n$summary\n\nالأثر السلوكي المستهدف: $behavioralImpact';
}
