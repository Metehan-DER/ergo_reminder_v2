class DailyQuote {
  final String textTr;
  final String textEn;
  final String category;

  const DailyQuote({
    required this.textTr,
    required this.textEn,
    required this.category,
  });
}

class DailyQuotes {
  static const List<DailyQuote> quotes = [
    // ── Duruş (Posture) ────────────────────────────────────────
    DailyQuote(
      textTr: "Omuzlarını gevşet. Muhtemelen fark etmeden yeniden kastın.",
      textEn: "Relax your shoulders. You probably tensed them again without noticing.",
      category: "Duruş",
    ),
    DailyQuote(
      textTr: "Duruşu zorla düzeltme, doğal dengeyi bul. Zorlanan beden daha çabuk yorulur.",
      textEn: "Don't force your posture — find the natural balance. A strained body tires faster.",
      category: "Duruş",
    ),
    DailyQuote(
      textTr: "Dirseklerin rahat, omuzların aşağıda olsun.",
      textEn: "Keep your elbows relaxed and your shoulders lowered.",
      category: "Duruş",
    ),
    DailyQuote(
      textTr: "90 derece kuralı: dirsekler, kalça ve dizler yaklaşık dik açıda olsun.",
      textEn: "The 90-degree rule: elbows, hips, and knees should sit at roughly right angles.",
      category: "Kanıta Dayalı",
    ),
    DailyQuote(
      textTr: "Sırtın sandalyeye, ayakların yere desteklensin.",
      textEn: "Let the chair support your back and keep your feet flat on the floor.",
      category: "Oturma Düzeni",
    ),
    DailyQuote(
      textTr: "Bir sonraki işe geçmeden önce oturuşunu bir kez kontrol et.",
      textEn: "Check your posture once before moving on to the next task.",
      category: "Duruş",
    ),
    DailyQuote(
      textTr: "Duruşunu düzeltirken kasılma. Rahat ve dengeli kal.",
      textEn: "Don't stiffen while correcting your posture. Stay relaxed and balanced.",
      category: "Duruş",
    ),
    DailyQuote(
      textTr: "İyi bir duruş, dik durmak değil; en az çaba ile dengede kalmaktır.",
      textEn: "Good posture isn't about standing rigid — it's balance with the least possible effort.",
      category: "Denge",
    ),

    // ── Göz Sağlığı (Eye Health) ─────────────────────────────────
    DailyQuote(
      textTr: "20-20-20 kuralı: her 20 dakikada bir, 20 saniye boyunca 6 metre uzağa bak.",
      textEn: "The 20-20-20 rule: every 20 minutes, look at something 20 feet away for 20 seconds.",
      category: "Kanıta Dayalı",
    ),
    DailyQuote(
      textTr: "Ekrana yaklaşmak yerine yazıları biraz büyüt.",
      textEn: "Increase the text size instead of leaning closer to the screen.",
      category: "Göz Sağlığı",
    ),
    DailyQuote(
      textTr: "Ekran, göz seviyesinin biraz altında ve bir kol boyu mesafede olmalı.",
      textEn: "Your screen should sit slightly below eye level, about an arm's length away.",
      category: "Kanıta Dayalı",
    ),
    DailyQuote(
      textTr: "Göz kırpmayı unutma. Ekrana odaklanınca bunu fark etmeden azaltıyorsun.",
      textEn: "Remember to blink. You blink less often than you think while focusing on a screen.",
      category: "Göz Sağlığı",
    ),
    DailyQuote(
      textTr: "Gözlerini birkaç saniye kapat ve yüz kaslarını gevşet.",
      textEn: "Close your eyes for a few seconds and let your facial muscles relax.",
      category: "Göz Dinlendirme",
    ),
    DailyQuote(
      textTr: "Uzağa bakmak gözlerine kısa bir dinlenme alanı açar.",
      textEn: "Looking into the distance gives your eyes a brief place to rest.",
      category: "Göz Dinlendirme",
    ),
    DailyQuote(
      textTr: "Ekran parlaklığı, çevredeki ışıkla uyumlu olmalı — ne kısılsın ne de gözünü kessin.",
      textEn: "Screen brightness should match the room around it — neither too dim nor too harsh.",
      category: "Ekran",
    ),

    // ── Boyun / Bilek (Neck / Wrist) ──────────────────────────────
    DailyQuote(
      textTr: "Başını öne uzatma. Ekranı kendine yaklaştır.",
      textEn: "Don't push your head forward — bring the screen closer instead.",
      category: "Boyun",
    ),
    DailyQuote(
      textTr: "Çeneni hafifçe geriye al ve boynunu uzat.",
      textEn: "Gently draw your chin back and lengthen your neck.",
      category: "Boyun",
    ),
    DailyQuote(
      textTr: "Telefonuna bakarken boynunu değil, telefonu kaldır.",
      textEn: "Raise your phone instead of bending your neck down toward it.",
      category: "Boyun",
    ),
    DailyQuote(
      textTr: "Başının ağırlığı öne her eğildikçe boynundaki yük katlanarak artar.",
      textEn: "Every degree your head tips forward multiplies the load on your neck.",
      category: "Kanıta Dayalı",
    ),
    DailyQuote(
      textTr: "Bileklerini düz tut. Klavyeye uzanmak zorunda kalmamalısın.",
      textEn: "Keep your wrists straight. You shouldn't have to reach for the keyboard.",
      category: "Bilek",
    ),
    DailyQuote(
      textTr: "Fareyi kendine yakın tut. Omzunu öne taşımak zorunda kalma.",
      textEn: "Keep the mouse close so you don't have to reach forward with your shoulder.",
      category: "Masa Düzeni",
    ),
    DailyQuote(
      textTr: "Parmaklarını aç, bileklerini çevir ve ellerini dinlendir.",
      textEn: "Open your fingers, rotate your wrists, and let your hands rest.",
      category: "El ve Bilek",
    ),

    // ── Mola / Hareket (Break / Movement) ──────────────────────
    DailyQuote(
      textTr: "Kısa bir mola, uzun süre ağrıyla çalışmaktan daha verimlidir.",
      textEn: "A short break is more productive than working through discomfort.",
      category: "Mola",
    ),
    DailyQuote(
      textTr: "Kısa ve sık molalar, nadir ve uzun molalardan daha uygulanabilirdir.",
      textEn: "Short, frequent breaks are easier to sustain than rare, long ones.",
      category: "Mola",
    ),
    DailyQuote(
      textTr: "Aynı pozisyonda uzun süre kalmak, iyi bir pozisyonu bile kötüleştirir.",
      textEn: "Staying in one position too long can make even a good posture uncomfortable.",
      category: "Hareket",
    ),
    DailyQuote(
      textTr: "Ayağa kalkmak için yorulmayı bekleme.",
      textEn: "Don't wait until you feel tired to stand up.",
      category: "Hareket",
    ),
    DailyQuote(
      textTr: "Bir dakika yürü. Zihnin de bedeninle birlikte hareket etsin.",
      textEn: "Walk for a minute. Let your mind move along with your body.",
      category: "Yürüyüş",
    ),
    DailyQuote(
      textTr: "Kalk, esne ve tekrar otur. Bazen gereken yalnızca budur.",
      textEn: "Stand up, stretch, and sit back down. Sometimes that's all you need.",
      category: "Esneme",
    ),
    DailyQuote(
      textTr: "Hareketsizlik dinlenmek değildir. Beden, küçük hareketlerle onarılır.",
      textEn: "Stillness isn't the same as rest. The body repairs itself through small movements.",
      category: "Hareket",
    ),
    DailyQuote(
      textTr: "Kan dolaşımı hareketle çalışır. Otururken bacaklarını hafifçe kıpırdat.",
      textEn: "Circulation depends on movement. Give your legs a gentle shake while seated.",
      category: "Kanıta Dayalı",
    ),

    // ── Su / Nefes (Hydration / Breath) ───────────────────────
    DailyQuote(
      textTr: "Su içmeyi işin bitince değil, çalışırken hatırla.",
      textEn: "Remember to drink water while working, not only after you finish.",
      category: "Su",
    ),
    DailyQuote(
      textTr: "Susuzluk hissetmeden önce vücudun zaten susuzdur.",
      textEn: "Your body is already dehydrated before you consciously feel thirsty.",
      category: "Kanıta Dayalı",
    ),
    DailyQuote(
      textTr: "Bir yudum su, bir dakikalık moladan daha az zaman alır.",
      textEn: "A sip of water takes less time than a one-minute break.",
      category: "Su",
    ),
    DailyQuote(
      textTr: "Birkaç derin nefes al ve göğsünü sıkıştıran duruşu bırak.",
      textEn: "Take a few deep breaths and release the posture compressing your chest.",
      category: "Nefes",
    ),
    DailyQuote(
      textTr: "Nefesini fark etmek, zihnini şu ana geri getirmenin en kısa yoludur.",
      textEn: "Noticing your breath is the shortest path back to the present moment.",
      category: "Nefes",
    ),
    DailyQuote(
      textTr: "Sığ nefes, gerilmiş bir bedenin işaretidir. Karnından nefes al.",
      textEn: "Shallow breathing is a sign of a tense body. Breathe from your belly instead.",
      category: "Nefes",
    ),

    // ── Farkındalık / Doğu Felsefesi (Mindfulness / Eastern) ──
    DailyQuote(
      textTr: "Bedenin şu an neredeyse, dikkatin de orada olsun.",
      textEn: "Wherever your body is right now, let your attention be there too.",
      category: "Farkındalık",
    ),
    DailyQuote(
      textTr: "Vücudun rahatsızlık sinyali veriyorsa, onu görmezden gelmek yerine pozisyon değiştir.",
      textEn: "When your body signals discomfort, change position instead of ignoring it.",
      category: "Farkındalık",
    ),
    DailyQuote(
      textTr: "Boyun ağrısını normal çalışma düzeninin bir parçası sayma.",
      textEn: "Don't treat neck pain as just a normal part of working.",
      category: "Farkındalık",
    ),
    DailyQuote(
      textTr: "Akışta kalmak, bedenini unutmak değildir; ikisi birlikte var olabilir.",
      textEn: "Being in flow doesn't mean forgetting your body — the two can coexist.",
      category: "Denge",
    ),
    DailyQuote(
      textTr: "Suyun taşa karşı direnmeden yol açması gibi, duruşunu da zorlamadan düzelt.",
      textEn: "Like water carving stone without resistance, correct your posture without forcing it.",
      category: "Denge",
    ),
    DailyQuote(
      textTr: "Küçük bir molayı ertelemek, bedenin büyük bir molaya mecbur bırakmasıyla sonuçlanır.",
      textEn: "Postponing a small break just means your body will eventually force a bigger one.",
      category: "Farkındalık",
    ),

    // ── Stoacı Bakış (Stoic Angle) ────────────────────────────
    DailyQuote(
      textTr: "Ağrıyı kontrol edemezsin ama duruşunu edebilirsin. Elindekine odaklan.",
      textEn: "You can't control the pain, but you can control your posture. Focus on what's in your hands.",
      category: "Stoacı Bakış",
    ),
    DailyQuote(
      textTr: "Bugünkü küçük ihmal, yarının büyük rahatsızlığıdır. Şimdi düzelt.",
      textEn: "Today's small neglect becomes tomorrow's real discomfort. Fix it now.",
      category: "Stoacı Bakış",
    ),
    DailyQuote(
      textTr: "Mükemmel duruşu bekleme, elindeki en iyi duruşla başla.",
      textEn: "Don't wait for the perfect posture — start with the best one available to you now.",
      category: "Stoacı Bakış",
    ),

    // ── Kanıta Dayalı / Ergonomi (Evidence-based / Ergonomics) ─
    DailyQuote(
      textTr: "Ekranın üst kenarı göz hizana yakın olsun.",
      textEn: "Keep the top edge of your screen close to eye level.",
      category: "Ekran Düzeni",
    ),
    DailyQuote(
      textTr: "Ayakların yere ulaşmıyorsa bir destek kullan.",
      textEn: "Use a footrest if your feet don't comfortably reach the floor.",
      category: "Oturma Düzeni",
    ),
    DailyQuote(
      textTr: "Bel boşluğunu küçük bir destekle rahatlatabilirsin.",
      textEn: "A small lumbar support can noticeably ease your lower back.",
      category: "Bel",
    ),
    DailyQuote(
      textTr: "Masanın altında bacaklarının rahatça hareket edebileceği alan bırak.",
      textEn: "Leave enough space under the desk for your legs to move freely.",
      category: "Masa Düzeni",
    ),
    DailyQuote(
      textTr: "Oturduğun yeri değil, oturuş şeklini düzenle.",
      textEn: "Adjust how you sit, not just where you sit.",
      category: "Ergonomi",
    ),
    DailyQuote(
      textTr: "İyi bir çalışma düzeni, bedenini unutmak zorunda bırakmaz.",
      textEn: "A good work routine shouldn't require you to ignore your body.",
      category: "Ergonomi",
    ),
    DailyQuote(
      textTr: "Sabit bir pozisyon yerine sık aralıklarla oturup ayakta durmayı dene.",
      textEn: "Instead of one fixed position, try alternating between sitting and standing.",
      category: "Kanıta Dayalı",
    ),
    DailyQuote(
      textTr: "Klavyeni öyle konumlandır ki bileklerin yukarı ya da aşağı kırılmasın.",
      textEn: "Position your keyboard so your wrists don't bend up or down.",
      category: "Kanıta Dayalı",
    ),

    // ── Günün Notu (Note of the day) ──────────────────────────
    DailyQuote(
      textTr: "Bugün kendine verebileceğin küçük iyilik: pozisyonunu değiştir.",
      textEn: "A small favor you can do for yourself today: change your position.",
      category: "Günün Notu",
    ),
    DailyQuote(
      textTr: "Vücudun senin en sadık ortağın. Ona bugün de birkaç dakika ayır.",
      textEn: "Your body is your most loyal partner. Give it a few minutes today too.",
      category: "Günün Notu",
    ),
    DailyQuote(
      textTr: "Bir alışkanlığı değiştirmek büyük bir kararla değil, küçük bir hatırlatmayla başlar.",
      textEn: "Changing a habit rarely starts with a big decision — it starts with a small reminder.",
      category: "Günün Notu",
    ),
  ];

  static DailyQuote getQuoteForToday() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays;

    return quotes[dayOfYear % quotes.length];
  }
}