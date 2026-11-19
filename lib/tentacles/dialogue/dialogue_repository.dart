import 'dialogue_model.dart';

class DialogueRepository {
  static List<DialogueLine> getDialogue(String id) {
    return _scripts[id] ??
        [
          DialogueLine(
            speaker: 'System',
            text: '[Missing dialogue ID: $id]',
          )
        ];
  }

  static final Map<String, List<DialogueLine>> _scripts = {
    'scene1_1': [
      DialogueLine(speaker: 'Unknown', text: 'Hello'),
    ],
    'scene1_2': [
      DialogueLine(speaker: 'Unknown', text: 'Not there'),
    ],
    'scene1_3': [
      DialogueLine(speaker: 'Unknown', text: "You'll find yourself eventually"),
    ],
    'scene1_4': [
      DialogueLine(
          speaker: 'Unknown',
          text: 'From those who failed, you exceed in descension'),
    ],
    'scene1_5': [
      DialogueLine(
          speaker: 'Unknown',
          text: 'Your debts are greater than what you could ever produce'),
    ],
    'scene1_6': [
      DialogueLine(speaker: 'Unknown', text: 'Give up'),
    ],
    'scene1_7': [
      DialogueLine(
        speaker: 'Unknown',
        text: 'Exit reality whilst you can',
        triggerJumpscare: true,
        jumpscareAsset: 'assets/images/Jumpscare.png',
        audioAsset: 'jumpscare_1.wav',
      ),
    ],
    'scene1_wake_office': [
      DialogueLine(
        speaker: 'Boss',
        text: 'Sleeping again?',
        setScene: 2,
      ),
    ],

    'scene2_boss': [
      DialogueLine(speaker: 'Boss', text: 'Are you really sleeping again?'),
      DialogueLine(speaker: 'Boss', text: 'Hm...'),
      DialogueLine(
          speaker: 'Boss', text: "You've clearly not slept for a while."),
      DialogueLine(
          speaker: 'Boss',
          text:
          "Look James, I know you're drowning in debt, and I'm really trying to help you."),
      DialogueLine(
          speaker: 'Boss',
          text:
          "I raised your salary not too long ago, but you've really got to help me out."),
      DialogueLine(speaker: 'Boss', text: "HR wouldn't let me do much more."),
      DialogueLine(speaker: 'Boss', text: '...'),
      DialogueLine(
        speaker: 'Boss',
        text: 'How about this, have an early leave for today, on me.',
        options: [
          DialogueOption(text: 'Really?', nextDialogueId: 'scene2_boss_end'),
          DialogueOption(text: '...', nextDialogueId: 'scene2_boss_end'),
        ],
      ),
    ],
    'scene2_boss_end': [
      DialogueLine(
          speaker: 'Boss',
          text: "Go ahead, I'll sort some things out. Get some rest."),
      DialogueLine(
        speaker: 'Boss',
        text: "You've been looking more and more... lifeless. Recently.",
        setFlag: 'boss_dismissed_day1',
      ),
    ],
    'scene2_sara': [
      DialogueLine(
        speaker: 'Sara',
        text: "Hope you get through whatever life's thrown at you.",
        options: [
          DialogueOption(
              text: 'Thank you, appreciate it.', nextDialogueId: 'scene2_sara_2'),
          DialogueOption(
              text: 'Hope you get through your family problems too, Sara.',
              nextDialogueId: 'scene2_sara_2'),
        ],
      ),
    ],
    'scene2_sara_2': [
      DialogueLine(
        speaker: 'Sara',
        text:
        'The matrix in the spreadsheet is missing some addresses, can you get that done later?',
        options: [
          DialogueOption(text: "I'll get it done as soon as possible."),
          DialogueOption(
              text: "Apologies, I'll try get it done tomorrow."),
        ],
      ),
    ],
    'scene2_hamza': [
      DialogueLine(
        speaker: 'Hamza',
        text: "How you doing brother, you don't look too good.",
        options: [
          DialogueOption(
              text: "I'm fine, how are you?", nextDialogueId: 'scene2_hamza_2'),
          DialogueOption(
              text: "Don't worry about me man, how are you?",
              nextDialogueId: 'scene2_hamza_2'),
        ],
      ),
    ],
    'scene2_hamza_2': [
      DialogueLine(
          speaker: 'Hamza',
          text:
          'I’m always good brother. I overheard you and the boss, go get some rest. Head to the elevator and pass this report to reception.'),
      DialogueLine(
        speaker: 'Hamza',
        text:
        "It's just a report that one of the receptionists requested, nothing crazy I promise.",
        setFlag: 'has_hamza_report',
        setScene: 3,
      ),
    ],
    'scene2_chan': [
      DialogueLine(
        speaker: 'Chan',
        text:
        'Get some rest bro, past few days ya been a lil hung over or something man. Hope ya get it figured out.',
        options: [
          DialogueOption(text: '...'),
          DialogueOption(text: 'Aight bro.'),
        ],
      ),
    ],
    'scene2_mitchell': [
      DialogueLine(
        speaker: 'Mitchell',
        text: "I'm excited to get home today.",
        options: [
          DialogueOption(
              text: 'Thanks for letting me know.',
              nextDialogueId: 'scene2_mitchell_2'),
          DialogueOption(
              text: 'What you gonna get up to?',
              nextDialogueId: 'scene2_mitchell_2'),
        ],
      ),
    ],
    'scene2_mitchell_2': [
      DialogueLine(
        speaker: 'Mitchell',
        text:
        "Well, we're gonna have some roast dinner, you know. Chicken, mash, the whole package. Pretty excited of course.",
        options: [
          DialogueOption(text: 'Good for you.'),
          DialogueOption(
              text: 'Hope you have a great time, sounds delightful.'),
        ],
      ),
    ],

    'scene3_receptionist': [
      DialogueLine(
        speaker: 'James',
        text: 'AH!',
        triggerJumpscare: true,
        jumpscareAsset: 'assets/images/Jumpscare.png',
        audioAsset: 'jumpscare.wav',
      ),
      DialogueLine(speaker: 'Receptionist', text: "What's that in your hands?"),
      DialogueLine(
          speaker: 'Receptionist', text: "Oh that's the report I requested."),
      DialogueLine(
          speaker: 'Receptionist', text: 'Thank you so much. Have a great day.'),
      DialogueLine(
        speaker: 'James',
        text: 'You... too I guess.',
        setFlag: 'report_delivered',
        setScene: 4,
      ),
    ],

    'scene4_cafe_hadel': [
      DialogueLine(
          speaker: 'Hadel',
          text: "How's everything been, it's been a week since we met."),
      DialogueLine(
          speaker: 'James',
          text:
          'Things have been getting a little more difficult, but life is life.'),
      DialogueLine(
          speaker: 'Hadel',
          text:
          "Yeah, I've got some stuff to share too. Work has been a little hectic, a lot going on back at my workplace."),
      DialogueLine(
          speaker: 'Hadel',
          text:
          'We signed with multiple agencies and now the workload is beyond our capabilities. Even HR is thinking of hiring more, but the boss said no.'),
      DialogueLine(
          speaker: 'James',
          text: "Well for us it's been smooth sailing, at work at least."),
      DialogueLine(speaker: 'Hadel', text: 'How come?'),
      DialogueLine(
          speaker: 'James',
          text:
          'My loan interest has increased, it looks virtually impossible to pay it off.'),
      DialogueLine(
          speaker: 'Hadel',
          text:
          "It's not that bad, my interest had also increased slightly, I've been struggling to eat regular food, not a morsel. Also, the food bank might close down due to lack of funding in their small town, so we might have to travel much further now to get their food parcels, which are measly on their own."),
      DialogueLine(
          speaker: 'James', text: "There's nowhere to turn for help anymore."),
      DialogueLine(
          speaker: 'Hadel', text: 'Every tunnel will always have an exit.'),
      DialogueLine(
          speaker: 'James',
          text: "Without you, I'd be unable to continue forwards."),
      DialogueLine(
          speaker: 'Hadel',
          text:
          "It's mutual, and if your landlord kicks you out, you can temporarily stay at my place."),
      DialogueLine(
          speaker: 'James', text: 'I have no idea where you live.'),
      DialogueLine(
          speaker: 'Hadel',
          text:
          "Let's hope I don't have to tell you. Have you finished your coffee?"),
      DialogueLine(speaker: 'James', text: 'Yes.'),
      DialogueLine(speaker: 'Hadel', text: 'Keep hope in its absence.'),
      DialogueLine(
        speaker: 'James',
        text: 'Same to you.',
        setFlag: 'cafe_complete',
        setScene: 5,
      ),
    ],

    'scene5_paranoia': [
      DialogueLine(
        speaker: 'James',
        text: 'AHH!',
        triggerJumpscare: true,
        jumpscareAsset: 'assets/images/Jumpscare.png',
        audioAsset: 'jumpscare.wav',
      ),
      DialogueLine(
          speaker: 'James',
          text:
          "I can't get this out of my head, it's been bothering me for so long."),
      DialogueLine(speaker: 'James', text: 'Should I be getting worried?'),
      DialogueLine(
          speaker: 'James',
          text:
          'Hadel did say I should visit a therapist, so did the receptionist.'),
      DialogueLine(
          speaker: 'James',
          text:
          'The receptionist is a weirdo though, should I really be listening to her?'),
      DialogueLine(
          speaker: 'James',
          text:
          "It's probably just a weird sleep paralysis demon thing, without the sleep paralysis."),
      DialogueLine(
          speaker: 'James',
          text:
          "That dream couldn't possibly mean I'd get chased, right?"),
      DialogueLine(
        speaker: 'James',
        text:
        "Why am I even wondering if the dream means anything, I'm just pathetic.",
        setScene: 6,
      ),
    ],

    'scene6_fridge': [
      DialogueLine(
        speaker: 'James',
        text:
        "Nothing but ketchup... not even bread for a ketchup sandwich. I'll just sleep to pass the hunger.",
        setFlag: 'checked_empty_fridge',
      ),
    ],
    'scene6_bed_sleep': [
      DialogueLine(speaker: 'James', text: 'What... is this?'),
      DialogueLine(
          speaker: 'Hadel', text: "I'm here to pay my monthly term."),
      DialogueLine(
          speaker: 'Banker',
          text: 'Okay Hadel, your amount this month is £2301.92.'),
      DialogueLine(
          speaker: 'Hadel',
          text:
          "That's a lot of money, haha, here it is. I already requested for his interest to be raised, he's on his last legs haha."),
      DialogueLine(
        speaker: 'Hadel',
        text:
        "Could you guys try to keep it constant for a while? Another rise and I won't be able to keep up.",
        setScene: 7,
      ),
      DialogueLine(speaker: 'James', text: 'Was... no...'),
      DialogueLine(
          speaker: 'James',
          text: 'Was that my payments he had in his hand?'),
      DialogueLine(
          speaker: 'James',
          text:
          'I worked so hard though, how could he just use my money like that?'),
      DialogueLine(
          speaker: 'James',
          text: 'I trusted him. Can I really not trust anyone anymore?'),
      DialogueLine(
        speaker: 'James',
        text: "It's just a dream James, just a dream.",
        setFlag: 'woke_from_bank_dream',
        setScene: 8,
      ),
    ],

    'scene8_reception': [
      DialogueLine(speaker: 'James', text: 'Morning.'),
      DialogueLine(
          speaker: 'Receptionist',
          text:
          'Hiya, you alright? Looking a little better than yesterday.'),
      DialogueLine(
          speaker: 'James',
          text:
          "Haha, yeah I'm feeling better, how's you and the children?"),
      DialogueLine(
          speaker: 'Receptionist',
          text: "We're doing well, just been much colder now hasn't it."),
      DialogueLine(
          speaker: 'James',
          text: "Far too cold, at least it's not bad in the building."),
      DialogueLine(speaker: 'Receptionist', text: 'Hm.', setScene: 9),
    ],
    'scene9_desk_investigate': [
      DialogueLine(
          speaker: 'James',
          text:
          'About last night, should I really check if my friend did that?'),
      DialogueLine(
          speaker: 'James',
          text:
          'It was just a dream probably. But... it wouldn’t hurt to check.'),
      DialogueLine(
          speaker: 'James',
          text: "You never know what's behind the eyes of the treacherous."),
      DialogueLine(
          speaker: 'James',
          text: "That's... not that far actually. I'll head to his after work."),
      DialogueLine(
        speaker: 'Boss',
        text:
        'I just saw you completed the spreadsheet matrices, good work today. Rest well.',
        setFlag: 'found_hadels_address',
        setScene: 10,
      ),
    ],

    'scene10_paranoia_street': [
      DialogueLine(
          speaker: 'Unknown', text: "You're in the same position, James."),
      DialogueLine(
          speaker: 'Unknown',
          text:
          "There's no escape to the iterations of life, it's all the same. The people, the work, the emotions."),
      DialogueLine(
          speaker: 'Unknown',
          text:
          "You're worthless and pathetic. Only if you could see behind the eyes, would you finally believe me."),
      DialogueLine(
          speaker: 'James', text: 'Who are you?? Stop bothering me!'),
      DialogueLine(speaker: 'Unknown', text: 'If only you knew.'),
    ],
    'scene10_front_door': [
      DialogueLine(
          speaker: 'Voice Inside',
          text:
          "AHHHH! Stop please, you don't have to hurt them! NO, NO! Please, just stop!"),
      DialogueLine(
          speaker: 'Hadel',
          text:
          "How... how are you doing man? I didn't know I gave you my address... anyways did your landlord really kick you out already?"),
      DialogueLine(
        speaker: 'Hadel',
        text: 'You look pale and disturbed... here come inside.',
        setScene: 11,
        autoTeleport: const MapTransitionTarget('friends_house.tmx', 160, 220),
      ),
    ],

    'scene11_confrontation': [
      DialogueLine(
          speaker: 'James',
          text:
          'This... is much better than I expected. I thought you were also in debt, why don’t you just sell all of this and pay everything off?'),
      DialogueLine(
          speaker: 'Hadel',
          text:
          'First off, you need to explain how you even found my house. Did you stalk me yesterday? Am I even safe from my own friends?'),
      DialogueLine(
          speaker: 'James',
          text:
          "What? I just came to discuss something that's been on my mind for a while. What could possibly matter so much to you about this house, that you're trying to keep it secret?"),
      DialogueLine(
          speaker: 'Hadel',
          text:
          'Well because not many people know I live here... anyways, what brings you here, has your landlord kicked you already?'),
      DialogueLine(
          speaker: 'James',
          text: "No, it's a long story, and I don't think you'd believe me."),
      DialogueLine(
          speaker: 'Hadel',
          text: "Of course I'd believe you, I'd take a bullet for you."),
      DialogueLine(
          speaker: 'James',
          text:
          'I had this dream of this anonymous figure showing me you passing my loan payments to the bank under your own name? So you were basically stealing my loan payments.'),
      DialogueLine(speaker: 'Hadel', text: "You're... crazy."),
      DialogueLine(
          speaker: 'James',
          text:
          "I saw that you had a deal with the loan company, but I wasn't sure so I came to ask."),
      DialogueLine(speaker: 'Hadel', text: "You're really out of your mind."),
      DialogueLine(
          speaker: 'James',
          text:
          'Stop deflecting! Is it really true, you’ve been using my situation to make money for yourself, and you’re living like a king.'),
      DialogueLine(
          speaker: 'Hadel',
          text:
          "It's not as it seems James, you're just crazy. I assure you this was all in our benefit. Remember James, we're in this together, we help each other out."),
      DialogueLine(
          speaker: 'James',
          text:
          'How... could you live lavishly when I sleep with just a mattress?'),
      DialogueLine(
          speaker: 'Hadel',
          text:
          "Look James, I'll explain later, but just calm down right now. I really need you to."),
      DialogueLine(
        speaker: 'James',
        text: '...',
        triggerJumpscare: true,
        jumpscareAsset: 'assets/images/Jumpscare.png',
        audioAsset: 'jumpscare.wav',
      ),
      DialogueLine(
        speaker: 'James',
        text: "He's really... gone. Who knew he was evil behind the eyes.",
        setFlag: 'hadel_killed',
        setScene: 12,
      ),
    ],

    'scene12_under_bed': [
      DialogueLine(
        speaker: 'James',
        text: 'AH!',
        triggerJumpscare: true,
        jumpscareAsset: 'assets/images/Jumpscare.png',
        audioAsset: 'jumpscare.wav',
      ),
    ],
    'scene12_bloody_toilet': [
      DialogueLine(
        speaker: 'James',
        text: 'A key... covered in blood. This must unlock the basement.',
        setFlag: 'has_basement_key',
        setScene: 13,
      ),
    ],

    'scene13_basement': [
      DialogueLine(
          speaker: 'Man with Bat',
          text:
          'Stop there or else I’ll... oh you must be James. I’ve heard great, great things about you.'),
      DialogueLine(
          speaker: 'Man with Bat',
          text:
          "I heard what you did up there, it was marvellous, brilliant. But you can't let these witnesses leave freely, we have to cover up everything don't we? Here, come on, deprive them of their existence, it only makes sense."),
      DialogueLine(
          speaker: 'James',
          text:
          "I... Hadel didn't tell me he had a family? Yeah... these are just witnesses."),
      DialogueLine(
          speaker: 'Man with Bat',
          text:
          'Exactly, exactly! These guys... just wanted to get the last bit of your wages. Finish them.'),
      DialogueLine(speaker: 'Mother', text: "Don't...!"),
      DialogueLine(
          speaker: 'Man with Bat', text: 'Haha... how foolish you are James.'),
      DialogueLine(speaker: 'James', text: 'What do you mean?'),
      DialogueLine(
          speaker: 'Man with Bat',
          text:
          'You really think your weak friend over there wanted to steal from you? His heart is too... pure and fragile for that.'),
      DialogueLine(speaker: 'James', text: 'So... what... who are you?'),
      DialogueLine(
          speaker: 'Man with Bat',
          text:
          "I kept his family hostage for... less than two years, until he'd pay up a ransom. If he missed a payment then he was to consider his family non-existent, even mentioning his family to others would result in the same fate."),
      DialogueLine(
          speaker: 'Man with Bat',
          text:
          'I was... generous... I only raised the asking amount every month.'),
      DialogueLine(speaker: 'James', text: 'You...'),
      DialogueLine(
          speaker: 'Man with Bat',
          text:
          "What? He just used you as a pawn to pay up. Not my problem. If you get home right now, you won't even need to see my face ever again. Go."),
      DialogueLine(
        speaker: 'James',
        text: '...',
        setFlag: 'truth_revealed',
        setScene: 14,
      ),
    ],

    'scene14_sleep_ending': [
      DialogueLine(speaker: 'Narrator', text: 'And just like that...'),
      DialogueLine(speaker: 'Narrator', text: 'He was no longer morseless.'),
      DialogueLine(speaker: 'Narrator', text: 'He was...'),
      DialogueLine(speaker: 'Narrator', text: 'Much'),
      DialogueLine(speaker: 'Narrator', text: 'Worse.'),
    ],
  };
}