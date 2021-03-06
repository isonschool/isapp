void main() {
  var res = [];
  var lines = terms.trim().split('\n');
  for (var line in lines) {
    res.add(line.replaceFirst(RegExp(r' *\[.*\]'), '').trim());
  }
  print(res.join('\n'));
}

const terms = '''
負[数学]
negatiewe [wiskunde]
mənfi [riyaziyyat]
negatif [matematika]
negatif [math]
negativan [math]
negatiu [matemàtiques]
negativní [math]
negativ [matematik]
Negativ [Math]
negatiivse [matemaatika]
negativo [matemáticas]
negatiboa [matematika]
negatibong [matematika]
négatif [math]
negativo [matemáticas]
negativni [matematike]
ezimbi [izibalo]
neikvæður [stærðfræði]
negativo [matematica]
hasi [hisabati]
negatīvs [math]
neigiamas [matematikos]
negatív [matematika]
negatief [wiskunde]
negativ [matte]
salbiy [matematik]
Ujemną wartość [Math]
negativo [matemática]
negativ [matematică]
negative [math]
negatívna [math]
negativno [Math]
negatiivinen [matematiikka]
negationen [math]
tiêu cực [math]
Negatif [matematik]
адмоўная [матэматыка]
отрицателно [математика]
терс [математика]
теріс [математика]
негативни [математика]
сөрөг [математикийн]
отрицательная [математика]
негативе [матх]
негативна [математика]
αρνητική [μαθηματικά]
բացասական [Մաթեմատիկա]
שלילי [מתמטיקה]
منفی [ریاضی]
سلبية [الرياضيات]
منفی [ریاضی]
नकारात्मक [गणित]
नकारात्मक [गणित]
नकारात्मक [गणित]
নেতিবাচক [গণিত]
ਨਕਾਰਾਤਮਕ [ਮੈਥ]
નકારાત્મક [ગણિત]
எதிர்மறையான [கணித]
ప్రతికూల [గణిత]
ನಕಾರಾತ್ಮಕ [ಗಣಿತ]
നെഗറ്റീവ് [മാത്ത്]
සෘණ [ගණිත]
เชิงลบ [คณิตศาสตร์]
ລົບ [ຄະນິດສາດ]
အနုတ်လက္ခဏာ [သင်္ချာ]
უარყოფით [math]
አሉታዊ [የሒሳብ]
អវិជ្ជមាន [គណិតវិទ្យា]
负[数学]
負[數學]
음의 [수학]
negativu [maths]
negatyf [math]
korau [ilimin lissafi]
na-adịghị mma [mgbakọ na mwepụ]
negatif [math]
neyînî [math]
negativ [temporäre]
ratsy [matematika]
negattiva [matematika]
kino [pāngarau]
منفي [ریاضی]
le lelei [o le matematika]
àicheil [math]
mpe [lipalo]
akaipa [masvomhu]
منفي [رياضي]
negative [xisaabta]
négatip [math]
манфӣ [математика]
negyddol [mathemateg]
negative [izibalo]
נעגאַטיוו [מאַט]
odi [isiro]
''';
