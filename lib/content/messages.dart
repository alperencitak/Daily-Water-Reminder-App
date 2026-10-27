import 'dart:math';

/// Long, language-specific text lists (Bob's lines and reminder messages).
/// Kept out of the ARB files because they are picked at random and are also
/// needed from background isolates, where there is no BuildContext.

bool _isTr(String languageCode) => languageCode == 'tr';

/// Replaced by the store screenshot tool to get a repeatable Bob.
Random messageRandom = Random();

T pickRandom<T>(List<T> items) => items[messageRandom.nextInt(items.length)];

enum BobMood { lol, angel, surprise, cry, anime, crazy, love, neutral, sleep }

const _bobEn = <BobMood, List<String>>{
  BobMood.lol: [
    '*Bob is happy because he drinks enough water every day.*',
    "Drink a glass of water. You'll thank me!",
    'Just one glass of water. Amazing!',
  ],
  BobMood.angel: [
    'A sip of water says more than a thousand words: Health, peace, energy.',
    '*One glass of water will refresh you. Bob always remembers this.*',
    'Drinking water refreshes the soul, come on, drink a glass!',
  ],
  BobMood.surprise: [
    'Did you know? Drinking enough water slows down the aging process of your skin.',
    'Drinking water can speed up your metabolism by up to 30%, which increases calorie burning.',
    'Drinking water can reduce headaches because dehydration often causes them.',
  ],
  BobMood.cry: [
    '*Bob is sad because you did not drink water*',
    '*Bob is sad because he forgot to drink water. Drink a glass so Bob can be happy!*',
    'I forgot to drink water!',
  ],
  BobMood.anime: [
    'Will you drink a glass of water for me?',
    'Excuse me, where can I get some water from?',
    'I already drank my glass of water.',
  ],
  BobMood.crazy: [
    "I bet you can't drink a glass of water in 20 seconds!",
    'I drank more water than you today.',
    "I'll reach my goal before you today.",
  ],
  BobMood.love: [
    'I admire your determination to drink water.',
    'I really love water.',
    'Water is very precious to me!',
  ],
  BobMood.neutral: [
    'Drinking water is like exercising, but much less exhausting!',
    'Your body needs water.',
    'I am Bob. I drink water.',
  ],
  BobMood.sleep: [
    '*Shh! Bob is sleeping.*',
    '*Bob drank water before going to sleep.*',
    '*zzzZZZ*',
  ],
};

const _bobTr = <BobMood, List<String>>{
  BobMood.lol: [
    '*Bob mutlu çünkü her gün yeterince su içiyor.*',
    'Bir bardak su iç. Bana teşekkür edeceksin!',
    'Sadece bir bardak su. Muhteşem!',
  ],
  BobMood.angel: [
    'Bir yudum su, bin kelimeden daha çok şey anlatır: Sağlık, huzur, enerji.',
    '*Bir bardak su, seni canlandırır. Bob bunu her zaman hatırlıyor.*',
    'Su içmek, ruhu dinlendirir, hadi bir bardak iç!',
  ],
  BobMood.surprise: [
    'Duydun mu? Yeterli su içmek, cildin yaşlanma sürecini yavaşlatıyormuş.',
    'Su içmek, metabolizmanı %30’a kadar hızlandırabilir, bu da kalori yakımını artırır.',
    'Su içmek, baş ağrılarını azaltabilir çünkü vücutta yeterli sıvı bulunmadığında baş ağrısı başlar.',
  ],
  BobMood.cry: [
    '*Bob su içmediğin için üzüldü*',
    '*Bob su içmeyi unuttuğu için üzülüyor. Bir bardak su iç, Bob mutlu olsun!*',
    'Su içmeyi unuttum!',
  ],
  BobMood.anime: [
    'Benim için bir bardak su içer misin?',
    'Pardon, acaba nereden su içebilirim?',
    'Ben bir bardak suyumu içtim.',
  ],
  BobMood.crazy: [
    'Bahse girerim 20 saniyede 1 bardak su içemezsin!',
    'Bugün senden daha fazla su içtim.',
    'Bugün hedefine senden önce ulaşırım.',
  ],
  BobMood.love: [
    'Su içme konusundaki kararlılığına hayranım.',
    'Suyu çok seviyorum.',
    'Su benim için çok değerli!',
  ],
  BobMood.neutral: [
    'Su içmek spor yapmak gibi, ama çok daha az yorucu!',
    'Vücudunun suya ihtiyacı var.',
    'Ben Bob. Su içerim.',
  ],
  BobMood.sleep: [
    '*Sessiz ol! Bob uyuyor.*',
    '*Bob uyumadan önce su içti.*',
    '*zzzZZZ*',
  ],
};

enum BobSituation { night, goalMet, behind, normal }

BobSituation bobSituation({required double progress, required DateTime now}) {
  if (now.hour >= 23 || now.hour < 6) return BobSituation.night;
  if (progress >= 1) return BobSituation.goalMet;
  if (now.hour >= 15 && progress < 0.35) return BobSituation.behind;
  return BobSituation.normal;
}

/// Picks Bob's mood from the situation instead of purely at random:
/// he celebrates a reached goal, sleeps at night and gets sad when you fall behind.
({BobMood mood, String line}) pickBob({
  required String languageCode,
  required double progress,
  required DateTime now,
}) {
  final mood = switch (bobSituation(progress: progress, now: now)) {
    BobSituation.night => BobMood.sleep,
    BobSituation.goalMet => pickRandom(const [
      BobMood.lol,
      BobMood.love,
      BobMood.angel,
    ]),
    BobSituation.behind => BobMood.cry,
    BobSituation.normal => pickRandom(const [
      BobMood.surprise,
      BobMood.anime,
      BobMood.crazy,
      BobMood.neutral,
      BobMood.angel,
      BobMood.lol,
    ]),
  };
  final lines = (_isTr(languageCode) ? _bobTr : _bobEn)[mood]!;
  return (mood: mood, line: pickRandom(lines));
}

const _reminderEn = [
  "Don't forget to drink water.",
  'Reward your body with a glass of water.',
  'Drink a glass of water for Bob.',
  'Your throat is dry, go drink some water.',
  "I heard you're going to drink a glass of water.",
  'Please give me a glass of water.',
  "I bet you can't drink water in 10 seconds.",
  "Why aren't you drinking water?",
  'Dude, drought is coming! Go drink a glass of water now!',
  "Didn't you hit your water goals today? Let's go!",
  'A glass of water clears your mind. How about trying it?',
  "Have you drunk enough water today? Let's have another glass!",
  'Go drink some water, maybe it tastes better today.',
  "Drink your water, I'm not kidding!",
  "It's time for a glass of water! How about drinking now?",
  "Come on, your water is calling 'Drink me!'",
  'Are you planning to end the day without drinking water? Is this a joke?',
  'A glass of water? Not such a hard task, come on!',
  'Drink your water, you can thank me later!',
  "Drinking water is free, don't miss the chance!",
  'Did you drink water today? Or are you always postponing it?',
  "Drink water! Because this notification won't say anything else!",
  "You thought about it but didn't drink, bravo! How do you take care of yourself like that?",
  "This notification won't go away without drinking water, just so you know.",
  "Today is the perfect day to drink water, you'll be late tomorrow anyway.",
  'Drink water! Because a great person like you deserves it.',
  'Are you waiting to drink your water? Are we creating an epic moment?',
  "Life is hard, I know. But drinking a glass of water shouldn't be that difficult.",
  "Sorry, this notification wouldn't bother you this much... if you had drunk water.",
  "If you're this strong, you can also manage to drink a glass of water!",
  'Your body needs charging just like your phone. Drink water!',
  'Did we have to send this many notifications for you to drink water? Come on!',
];

const _reminderTr = [
  'Su içmeyi unutma.',
  'Vücudunu bir bardak su ile ödüllendir.',
  'Bob için bir bardak su iç.',
  'Boğazın kurudu, git su iç.',
  'Bir bardak su içeceğini duydum.',
  'Lütfen bana bir bardak su ver.',
  'Bence 10 saniyede su içemezsin.',
  'Su niye içmiyorsun?',
  'Dostum, kuraklık kapıda! Hemen bir bardak su iç!',
  'Bugün litreleri devirmedin mi? Hadi bakalım!',
  'Bir bardak su, zihnini berraklaştırır. Denemeye ne dersin?',
  'Bugün yeterince su içtin mi? Hadi bir bardak daha!',
  'Hadi su iç, belki suyun tadı bugün daha güzeldir.',
  'Suyunu iç, şaka yapmıyorum!',
  'Bir bardak su zamanı! Şimdi içmeye ne dersin?',
  "Hadi dostum, suyun sana 'beni iç' diyor!",
  'Bugün su içmeden günü kapatmayı mı planlıyorsun? Şaka mı bu?',
  'Bir bardak su mu? Çok zor bir görev değil, hadi başla!',
  'Suyunu iç, sonra teşekkür edebilirsin!',
  'Su içmek ücretsizdir, fırsatı kaçırma!',
  'Bugün su içtin mi? Yoksa hep mi erteliyorsun?',
  'Su iç! Çünkü bu bildirim başka bir şey söylemeyecek!',
  'Düşündün ama su içmedin, bravo! Kendine nasıl iyi bakıyorsun öyle?',
  'Bu bildirim su içmeden gitmeyecek, benden söylemesi.',
  'Bugün su içmek için mükemmel bir gün, yarın zaten geç kalmış olursun.',
  'Su iç! Çünkü senin gibi harika bir insan bunu hak ediyor.',
  'Suyu içmek için mi bekliyorsun? Efsane bir an mı yaratacağız?',
  'Hayat zor, biliyorum. Ama bir bardak su içmek bu kadar da zor olmamalı.',
  'Kusura bakma, bu bildirim seni bu kadar rahatsız etmezdi... Eğer su içseydin.',
  'Bu kadar güçlüysen, bir bardak su içmeyi de başarabilirsin!',
  'Telefonun kadar vücudun da şarj edilmeye ihtiyaç duyuyor. Su iç!',
  'Su içmek için bu kadar bildirim göndermemiz mi gerekiyordu? Hadi ama!',
];

List<String> reminderMessages(String languageCode) =>
    _isTr(languageCode) ? _reminderTr : _reminderEn;
