//
//  SacredSiteData.swift
//  Leyhome - 地脉归途
//
//  预置圣迹数据 - Tier 1 源点圣迹 + Tier 2 地脉节点
//
//  Created on 2026/01/30.
//

import Foundation

struct SacredSiteData {

    // MARK: - Load All

    static func loadAllSites() -> [SacredSite] {
        var sites: [SacredSite] = []

        for data in primalSites {
            sites.append(createSite(from: data, tier: .primal))
        }
        for data in leyNodes {
            sites.append(createSite(from: data, tier: .leyNode))
        }

        return sites
    }

    // MARK: - Tier 1 源点圣迹 (14)
    // 基石(4): 冈仁波齐、吉萨金字塔、哥贝克力石阵、瓦拉纳西
    // 智慧(3): 德尔斐、嵩山、耶路撒冷
    // 失落(3): 马丘比丘、三星堆、拉帕努伊岛
    // 美学(2): 黄山、贝加尔湖
    // 极境(2): 北极圈、南极大陆

    static let primalSites: [[String: Any]] = [

        // ═══════════════════════════════════════════
        // 第一类：基石圣迹 (The Primordial Pillars)
        // ═══════════════════════════════════════════

        [
            "nameZh": "冈仁波齐",
            "nameEn": "Mount Kailash",
            "descriptionZh": "冈仁波齐是印度教、藏传佛教、耆那教与苯教共尊的世界中心，传说中须弥山的化身。它不代表某个特定宗教，而是「朝圣」这一行为本身——是向心的本能。对地脉归途而言，它是「回归本源」的最高象征，是星球能量的顶点。",
            "descriptionEn": "Mount Kailash is revered as the center of the world by Hinduism, Tibetan Buddhism, Jainism, and Bön — the earthly manifestation of Mount Meru. It represents not any single religion, but the act of pilgrimage itself — the instinct to return to the source, the supreme symbol of homecoming.",
            "loreZh": "在西藏阿里地区海拔六千六百余米的冰雪之巅，冈仁波齐以近乎完美的金字塔形态矗立于天地之间，被四大宗教——印度教、藏传佛教、耆那教与苯教——共尊为世界的中心。它是传说中须弥山在人间的化身，是宇宙的轴心（Axis Mundi），是连接天界与尘世的通道。\n\n千百年来，无数朝圣者跋涉千里来到这里，以身体丈量这座圣山。他们在五十二公里的转山路上匍匐前行，每一次五体投地都是灵魂的一次洗涤。藏族人相信，转山一圈可洗净一世罪孽，转十三圈可免受地狱之苦，而转一百零八圈便能在今世成佛。\n\n冈仁波齐的特殊之处在于，它代表的不是某一个特定的宗教或信仰体系，而是「朝圣」这一人类最古老行为本身。那种抛下一切、只为接近某种更高存在的冲动，是刻入灵魂深处的本能——向心的本能。当你远远望见那座冰雪覆盖的金字塔形山峰在晨光中泛着金色光芒，你会明白为什么四种截然不同的信仰都不约而同地选择了同一座山作为精神的归宿。万法归宗，归于此峰。",
            "loreEn": "At over 6,600 meters in the Ngari region of Tibet, Mount Kailash stands between heaven and earth in an almost perfect pyramidal form, revered by four religions — Hinduism, Tibetan Buddhism, Jainism, and Bön — as the center of the world. It is the earthly manifestation of Mount Meru, the Axis Mundi, the passage connecting the celestial and the mortal.\n\nFor millennia, countless pilgrims have trekked thousands of miles to measure this sacred mountain with their bodies. Along the 52-kilometer kora path, they prostrate forward step by step, each full-body bow a cleansing of the soul. Tibetans believe one circumambulation washes away a lifetime of sins, thirteen spare you from hell, and one hundred and eight grant Buddhahood in this very life.\n\nWhat makes Kailash extraordinary is that it represents not any single religion or belief system, but the most ancient of human acts — pilgrimage itself. That impulse to leave everything behind, to draw closer to something higher, is an instinct etched deep in the soul. When you glimpse that snow-capped pyramid glowing golden in the morning light, you understand why four utterly different faiths all chose the same mountain as their spiritual home. All paths converge upon this peak.",
            "latitude": 31.0672,
            "longitude": 81.3119,
            "continent": "Asia",
            "country": "China",
            "region": "Tibet"
        ],
        [
            "nameZh": "吉萨金字塔",
            "nameEn": "Giza Pyramids",
            "descriptionZh": "金字塔是人类对「超越死亡」最恢宏的想象和尝试。它连接着天地、星辰与不朽的灵魂，其几何构造本身就是一部关于能量与宇宙的神秘法典。它引导人们思考「时间」与「存在」的终极意义，是永恒的象征。",
            "descriptionEn": "The pyramids are humanity's most magnificent attempt to transcend death. Connecting heaven, earth, stars and immortal souls, their geometry is a cryptic codex of energy and cosmos, guiding contemplation of the ultimate meaning of time and existence — the archetype of eternity.",
            "loreZh": "四千五百年前，当世界上大多数文明尚在萌芽之时，古埃及人便在尼罗河西岸矗立起了这座旷世奇迹。吉萨金字塔不仅是法老胡夫的陵寝，更是人类对「永恒」最宏伟的宣言——它以二百三十万块巨石、跨越数十年的营造，向死亡本身发起了挑战。\n\n金字塔的每一个维度都暗藏着精密的宇宙密码。它的四面精确朝向东南西北，误差不超过三分之一度；底边周长与高度的比值近乎等于二倍圆周率；三座金字塔的排列对应着猎户座腰带三星的位置——仿佛地上的建筑只是天上星图的投影。这一切都在无声地诉说：建造者所掌握的知识，远超我们的认知。\n\n站在金字塔脚下，你会经历一种奇特的时间错觉。四千五百年的光阴在这些巨石面前变得微不足道，而你自身短暂的生命却因此获得了某种参照。金字塔不回答「生命为何终结」的问题，却以自身的存在证明了一件事：人类有能力创造超越自己寿命的永恒之物。当落日将最后一缕金光洒在石壁上，你将真正理解什么是「永恒」——不是时间的无限延伸，而是在有限中创造出的不朽意义。",
            "loreEn": "Four and a half millennia ago, when most civilizations were still in their infancy, the ancient Egyptians erected this marvel on the west bank of the Nile. The Great Pyramid of Giza is more than Pharaoh Khufu's tomb — it is humanity's grandest declaration of eternity, challenging death itself with 2.3 million stone blocks and decades of construction.\n\nEvery dimension conceals precise cosmic codes. Its four faces align to the cardinal directions within a third of a degree; the ratio of base perimeter to height approximates twice pi; the three pyramids mirror the alignment of Orion's Belt — as if these earthly structures are projections of a celestial map. All of this silently proclaims: the builders possessed knowledge far beyond our understanding.\n\nStanding at the pyramid's base, you experience a strange dislocation of time. Four and a half thousand years become insignificant before these stones, while your own brief life gains a frame of reference. The pyramid does not answer why life ends, but proves through its very existence that humans can create something that outlasts themselves. As the last golden light of sunset falls upon the stone walls, you will truly understand eternity — not the infinite extension of time, but the immortal meaning created within the finite.",
            "latitude": 29.9792,
            "longitude": 31.1342,
            "continent": "Africa",
            "country": "Egypt"
        ],
        [
            "nameZh": "哥贝克力石阵",
            "nameEn": "Göbekli Tepe",
            "descriptionZh": "作为已知的人类首座神庙，哥贝克力石阵标志着人类意识的一次伟大跃迁——从纯粹的生存，转向对「神圣」的思考。它颠覆了先有农业后有文明的理论，是文明与信仰的「零点」，是归途所能追溯到的最古老精神源头。",
            "descriptionEn": "As the oldest known human temple, Göbekli Tepe marks a great leap in human consciousness — from pure survival to contemplation of the sacred. It overturns the theory that agriculture preceded civilization, standing as the zero point of faith and the oldest spiritual origin the homeward path can trace.",
            "loreZh": "在土耳其东南部的荒原之上，沉睡着一个改写人类文明史的秘密。哥贝克力石阵比吉萨金字塔早七千年，比巨石阵早六千年——一万两千年前，当我们的祖先还是游荡在草原上的狩猎采集者时，便已在此竖起了高达五米、重达十数吨的T形石柱，并在其上精心雕刻着狐狸、蛇、秃鹫等神秘的动物图腾。\n\n这一发现彻底颠覆了考古学的基本假设。长久以来，学界坚信「农业催生定居，定居催生文明，文明催生信仰」的线性进程。但哥贝克力石阵证明了一个惊人的反转：也许是对「神圣」的思考和集体仪式的需求，而非填饱肚子的实际考量，催生了人类最初的聚落与协作。换言之，不是面包，而是信仰，点燃了文明的第一簇火苗。\n\n更令人困惑的是，在使用了约两千年后，建造者们竟刻意将整座神庙掩埋在泥土之下，仿佛要将某种秘密封印于大地深处。这是已知最古老的人类圣殿，是文明与信仰的绝对「零点」。站在这里，你所触摸的不是某段历史，而是人类意识觉醒的那一个决定性瞬间——从懵懂的生存，第一次抬头仰望星空，开始追问「我们从何而来」。",
            "loreEn": "On the barren plains of southeastern Turkey sleeps a secret that rewrites the history of human civilization. Göbekli Tepe predates the pyramids by seven thousand years, Stonehenge by six thousand. Twelve thousand years ago, when our ancestors were still hunter-gatherers roaming the grasslands, they erected T-shaped stone pillars up to five meters tall and weighing over ten tons, intricately carved with mysterious animal totems — foxes, serpents, vultures.\n\nThis discovery shattered archaeology's fundamental assumptions. For decades, scholars believed in a linear progression: agriculture begat settlement, settlement begat civilization, civilization begat faith. But Göbekli Tepe proves a stunning reversal: perhaps it was the contemplation of the sacred and the need for collective ritual — not the practical matter of filling bellies — that gave birth to humanity's first communities. In other words, not bread but faith ignited civilization's first spark.\n\nEven more puzzling, after roughly two thousand years of use, the builders deliberately buried the entire temple under soil, as if sealing some secret deep within the earth. This is the oldest known human sanctuary, the absolute zero point of civilization and faith. Standing here, you touch not a chapter of history, but the decisive moment of human awakening — when we first looked up at the stars and began to ask: where do we come from?",
            "latitude": 37.2233,
            "longitude": 38.9225,
            "continent": "Asia",
            "country": "Turkey",
            "region": "Şanlıurfa"
        ],
        [
            "nameZh": "瓦拉纳西",
            "nameEn": "Varanasi",
            "descriptionZh": "恒河岸边的这座圣城，是「生与死」最直观、最震撼的展现。印度教徒相信在此死去便能跳出轮回。它不避讳终结，反而将其视为新生的一部分，教会人们接纳生命的完整循环，理解「归途」的最终目的地。",
            "descriptionEn": "This holy city on the banks of the Ganges is the most vivid, most powerful embodiment of life and death. Hindus believe dying here liberates the soul from reincarnation. It embraces ending as part of rebirth, teaching acceptance of life's complete cycle.",
            "loreZh": "瓦拉纳西是世界上最古老的持续有人居住的城市之一，在恒河的怀抱中已经呼吸了三千余年。它是印度教徒心中最神圣的所在——湿婆神的居所，宇宙的精神中心。在这里，生与死不是被隔离的两个世界，而是同一条河流的两岸，彼此凝视，浑然一体。\n\n清晨，数以千计的信徒走下八十四座石阶，在恒河中沐浴净身，吟诵着古老的梵语祈祷。与此同时，仅几百米之外的摩尼卡尼卡河坛上，火葬的柴堆日夜不息地燃烧——据说这火焰已经连续燃烧了五千年，从未熄灭。新生婴儿的啼哭、修行者的冥想、亡者的最后一程，在同一片河岸上同时上演。\n\n印度教徒相信，在瓦拉纳西死去的灵魂能够直接获得解脱，跳出永无止境的轮回之苦。因此，无数老人在生命的尾声选择来此等候最后的时刻，以一种外人难以理解的安详面对终结。瓦拉纳西不教你逃避死亡，而是教你直视它、接纳它、理解它是循环中不可或缺的一环。当你走过那些被岁月打磨得光滑的石阶，你将亲眼目睹人类面对「终结」时最坦然的姿态——不是恐惧，而是释然。",
            "loreEn": "Varanasi is one of the oldest continuously inhabited cities in the world, breathing in the embrace of the Ganges for over three thousand years. It is the holiest site in the Hindu heart — the abode of Shiva, the spiritual center of the cosmos. Here, life and death are not two isolated worlds but two banks of the same river, gazing at each other, inseparable.\n\nAt dawn, thousands of devotees descend eighty-four ghats to bathe in the Ganges, chanting ancient Sanskrit prayers. Meanwhile, just a few hundred meters away at Manikarnika Ghat, funeral pyres burn ceaselessly — it is said these flames have burned continuously for five thousand years, never extinguished. A newborn's cry, a meditator's silence, and a soul's final journey unfold simultaneously on the same riverbank.\n\nHindus believe that souls departing in Varanasi achieve moksha — liberation from the endless cycle of rebirth. Countless elders choose to spend their final days here, facing the end with a serenity that outsiders find hard to comprehend. Varanasi does not teach you to flee from death, but to face it, accept it, and understand it as an indispensable part of the cycle. Walking down those stone steps worn smooth by centuries, you will witness humanity's most composed posture before the end — not fear, but release.",
            "latitude": 25.3176,
            "longitude": 83.0064,
            "continent": "Asia",
            "country": "India"
        ],

        // ═══════════════════════════════════════════
        // 第二类：智慧圣迹 (The Wisdom Sanctuaries)
        // ═══════════════════════════════════════════

        [
            "nameZh": "德尔斐",
            "nameEn": "Delphi",
            "descriptionZh": "德尔斐是古希腊人心中世界的中心——「大地的肚脐」。神庙入口刻着的「认识你自己」，是西方哲学的基石。这里是与内心神谕对话的地方，引导人们向内探索，在自身深处寻求答案。对地脉归途而言，它是自省之旅的起点。",
            "descriptionEn": "Delphi was the center of the world to the ancient Greeks — the Omphalos, navel of the earth. The inscription 'Know Thyself' at its temple entrance is the cornerstone of Western philosophy. It is a place for communing with the oracle within, the starting point of the journey inward.",
            "loreZh": "在帕纳索斯山的褶皱之间，德尔斐俯瞰着一片由橄榄树织成的银绿色峡谷，仿佛大地在此处深深地吸了一口气，然后屏住了呼吸。古希腊人相信这里是世界的中心——传说宙斯从世界的两端各放出一只鹰，它们在德尔斐的上空相遇，于是这里便成为大地的肚脐（Omphalos），成为凡人可以聆听神意的唯一窗口。\n\n在阿波罗神殿的幽暗深处，女祭司皮提亚端坐于一道从岩缝中涌出的气体之上，进入恍惚状态，口中吐出的含糊话语被祭司们解读为阿波罗的神谕。希腊世界的战争与和平、城邦的命运、帝王的抉择，都曾系于她一言。\n\n然而，在所有这些宏大的预言之前，每一位求问者首先会在神庙入口看到那句铭刻于石头上的古老训诫——「γνῶθι σεαυτόν」，认识你自己。这短短四个字，是西方哲学的基石，也是地脉归途最核心的主题。德尔斐告诉我们：你所寻求的一切答案，不在远方的某个神殿中，不在某位智者的话语里，而在你自己的心底深处。真正的神谕，是你内心的声音。来到这里，你寻找的不是未来的预言，而是与自我最诚实的对话。",
            "loreEn": "Nestled in the folds of Mount Parnassus, Delphi overlooks a silver-green valley woven with olive trees, as if the earth took a deep breath here and held it. The ancient Greeks believed this was the center of the world — legend has it that Zeus released an eagle from each end of the earth, and they met above Delphi, marking it as the Omphalos, the navel of the world, the only window through which mortals could hear the voice of the divine.\n\nIn the shadowy depths of Apollo's temple, the priestess Pythia sat over vapors rising from cracks in the rock, entering a trance, her murmured words interpreted by priests as Apollo's oracles. The wars and peace of the Greek world, the fates of city-states, the choices of kings — all once hung upon her utterance.\n\nYet before all these grand prophecies, every supplicant first encountered the ancient admonition carved in stone at the temple entrance — 'γνῶθι σεαυτόν,' Know Thyself. These few words are the cornerstone of Western philosophy and the core theme of the homeward path. Delphi tells us: every answer you seek lies not in some distant temple, not in a sage's words, but deep within your own heart. The true oracle is the voice within. Coming here, you seek not a prophecy of the future, but the most honest dialogue with yourself.",
            "latitude": 38.4824,
            "longitude": 22.5010,
            "continent": "Europe",
            "country": "Greece"
        ],
        [
            "nameZh": "嵩山",
            "nameEn": "Mount Songshan",
            "descriptionZh": "作为「天地之中」，嵩山并非以最高或最险著称，而是以「中正」和「包容」为核心。少林寺的禅武合一、嵩阳书院的儒学智慧、道教的天人合一，三教在此交汇，使其成为调和各种思想、寻求内在平衡与和谐的终极道场。",
            "descriptionEn": "As the 'Center of Heaven and Earth,' Mount Songshan is known not for height or peril, but for balance and inclusiveness. Shaolin's fusion of Zen and martial arts, Songyang Academy's Confucian wisdom, and Taoist harmony converge here — the ultimate sanctuary for inner equilibrium.",
            "loreZh": "嵩山居五岳之中，不偏不倚，自古被尊为「天地之中」。它没有泰山的雄浑霸气，也没有华山的险绝凌厉，却以一种更为深沉的力量屹立于中原大地——那是「中正」与「包容」的力量，是能够容纳万物、调和百家的精神气度。\n\n在嵩山的怀抱中，三种截然不同的思想体系找到了共存的空间。少室山下的少林寺，达摩面壁九年悟道，开创了禅宗的东土传承，又将佛法与武学熔于一炉，诞生了「禅武合一」的独特传统——以拳入禅，以禅御拳，身体的修炼即是心灵的修行。太室山下的嵩阳书院，程颢、程颐在此讲学论道，奠定了宋代理学的根基，「天理」与「人欲」的辩证在晨钟暮鼓中回荡了千年。而中岳庙的道教祭祀则延续着更为古老的天人感应传统，天地之气在这五岳正中汇聚交融。\n\n嵩山的智慧在于：它不主张任何一种思想的绝对正确，而是提供了一个让所有思想共鸣的空间。儒家的「入世」、佛家的「出世」、道家的「顺世」，在这座山上不再是矛盾，而是同一个真理的三个面向。嵩山教给你的不是某一种答案，而是一种能力——在纷繁复杂的世界中找到自己的「中」，在看似对立的事物间发现和谐与平衡。",
            "loreEn": "Mount Songshan stands at the center of the Five Sacred Mountains, perfectly balanced, venerated since antiquity as the Center of Heaven and Earth. It lacks the imposing grandeur of Mount Tai or the precipitous danger of Mount Hua, yet stands upon the Central Plains with a deeper power — the power of balance and inclusiveness, the spiritual magnanimity to embrace all things and harmonize all schools of thought.\n\nWithin Songshan's embrace, three utterly different philosophical systems found space to coexist. At the foot of Shaoshi Peak, Bodhidharma meditated facing a wall for nine years at the Shaolin Temple, establishing the Eastern transmission of Chan Buddhism and forging dharma with martial arts into the unique tradition of 'Zen-martial unity' — entering meditation through fist, governing fist through meditation. Below Taishi Peak, the brothers Cheng Hao and Cheng Yi lectured at Songyang Academy, laying the foundations of Song Dynasty Neo-Confucianism. And at the Zhongyue Temple, Taoist rites continue the ancient tradition of heaven-earth resonance.\n\nSongshan's wisdom lies in this: it does not advocate the absolute correctness of any single philosophy, but offers a space where all philosophies resonate. Confucian engagement with the world, Buddhist transcendence of it, Taoist flowing with it — on this mountain, these are no longer contradictions but three facets of the same truth. What Songshan teaches is not a particular answer, but an ability — to find your own center amid complexity, to discover harmony and balance between seeming opposites.",
            "latitude": 34.4844,
            "longitude": 113.0390,
            "continent": "Asia",
            "country": "China",
            "region": "Henan"
        ],
        [
            "nameZh": "耶路撒冷",
            "nameEn": "Jerusalem",
            "descriptionZh": "耶路撒冷是犹太教、基督教和伊斯兰教共同的「应许之地」，是地球上信仰能量密度最高的城市。它的存在本身，就讲述了一个关于信念、冲突、渴望与和平的、数千年未曾间断的宏大故事，是信仰力量的终极见证。",
            "descriptionEn": "Jerusalem is the shared 'Promised Land' of Judaism, Christianity, and Islam — the city of highest spiritual density on Earth. Its very existence tells an unbroken story of belief, conflict, longing, and peace spanning millennia, the ultimate testament to the power of faith.",
            "loreZh": "在这座不足一平方公里的老城中，三大天启宗教的至圣之所彼此相邻、彼此凝视、彼此纠缠了三千年。犹太人来到西墙前，将写满祈祷的纸条塞入石缝——这是所罗门圣殿仅存的遗迹，是流散两千年的民族最后的精神锚点。基督徒走进圣墓教堂，在传说中耶稣被钉十字架和复活的地方跪地祈祷——每一块石板都被千年来朝圣者的膝盖磨得光亮。穆斯林仰望岩石圆顶清真寺的金色穹顶——先知穆罕默德从这块岩石上夜行登霄，升入七重天。三种信仰，三个叙事，指向同一片天空。\n\n没有任何一座城市承载过如此浓烈的人类情感。为了它，十字军远征了两百年；为了它，萨拉丁立下不伤一人的誓言；为了它，无数信徒在漫漫长路上献出了一生。耶路撒冷见证了人类信仰最崇高的瞬间，也见证了以信仰之名犯下的最深的罪孽。它是一面镜子，映照出信念的力量，也映照出执念的代价。\n\n站在橄榄山上俯瞰这座金色之城，你会看到清真寺的宣礼塔、教堂的钟楼和犹太会堂的穹顶在同一片天际线上交织。在这里，你不需要属于任何一种信仰，便能感受到那股贯穿三千年的、炽烈得近乎灼人的力量——人类对神圣的渴望。",
            "loreEn": "Within this Old City of less than one square kilometer, the holiest sites of three Abrahamic religions have stood side by side, gazing at and entangling with each other for three thousand years. Jews approach the Western Wall, pressing prayer notes into its crevices — the sole remnant of Solomon's Temple, the last spiritual anchor of a people dispersed for two millennia. Christians enter the Church of the Holy Sepulchre, kneeling in prayer where Jesus was crucified and resurrected — every flagstone worn smooth by a thousand years of pilgrims' knees. Muslims gaze up at the golden Dome of the Rock — from this stone, the Prophet Muhammad ascended through seven heavens on his Night Journey. Three faiths, three narratives, pointing at the same sky.\n\nNo city has ever borne such intense human emotion. For it, Crusaders campaigned for two hundred years; for it, Saladin swore to harm no one; for it, countless believers gave their entire lives on endless pilgrim roads. Jerusalem has witnessed faith's most sublime moments and the deepest sins committed in faith's name. It is a mirror reflecting both the power of belief and the cost of obsession.\n\nStanding on the Mount of Olives overlooking this golden city, you see minarets, bell towers, and synagogue domes interweaving on the same skyline. Here, you need not belong to any faith to feel that force running through three millennia — humanity's fierce, almost scorching longing for the divine.",
            "latitude": 31.7683,
            "longitude": 35.2137,
            "continent": "Asia",
            "country": "Israel"
        ],

        // ═══════════════════════════════════════════
        // 第三类：失落圣迹 (The Lost Worlds)
        // ═══════════════════════════════════════════

        [
            "nameZh": "马丘比丘",
            "nameEn": "Machu Picchu",
            "descriptionZh": "一座突然消失在历史中的「天空之城」，隐匿于安第斯云雾之中的文明奇迹。它代表了所有我们无法解释的、美丽的谜团，激发人们的好奇心，去探索那些被遗忘的道路，追寻散落在时间深处的失落记忆。",
            "descriptionEn": "A sky city that suddenly vanished from history, a wonder of civilization hidden in the mists of the Andes. It represents every beautiful mystery that defies explanation, inspiring curiosity to explore forgotten paths and pursue lost memories scattered in the depths of time.",
            "loreZh": "在安第斯山脉海拔两千四百余米的云雾之中，马丘比丘如同一座被时间遗忘的天空之城。五百多年前，印加帝国在西班牙征服者到来之际，将这座城市彻底遗弃，任由藤蔓和云雾将其吞噬。直到1911年，美国探险家海勒姆·宾厄姆在当地农民的指引下，才重新揭开了这座失落之城的面纱。\n\n这里的每一块石头都不用灰浆，却严丝合缝得连刀片也无法插入。太阳神殿的窗户在冬至日准确地框住初升的太阳，拴日石（Intihuatana）的棱角与周围山峰的轮廓完美对应——印加人在此构建的不仅是一座城市，而是一个与天地星辰精密对话的宇宙模型。\n\n但最大的谜团是：他们为何离开？没有战争的痕迹，没有瘟疫的证据，没有任何关于这座城市的文字记录。它就这样安静地消失在了历史的褶皱中，带走了所有的答案。也许这正是马丘比丘最深刻的魅力——它不给你确定性，只给你无穷的好奇。它是一扇通往「迷失」的门：迷失于云雾、迷失于时间、迷失于那些我们永远无法完全理解的美丽谜团之中。在这里迷失，本身就是一种找到。",
            "loreEn": "At over 2,400 meters in the mists of the Andes, Machu Picchu stands like a sky city forgotten by time. Over five hundred years ago, as Spanish conquistadors approached, the Inca Empire abandoned this city entirely, leaving vines and clouds to swallow it. Not until 1911 did explorer Hiram Bingham, guided by local farmers, lift the veil on this lost city.\n\nEvery stone here was laid without mortar, yet fitted so precisely that not even a blade can slip between them. The Temple of the Sun's windows frame the rising sun precisely on the winter solstice; the edges of the Intihuatana stone align perfectly with the surrounding mountain silhouettes. The Inca built here not merely a city, but a cosmic model in precise dialogue with heaven, earth, and stars.\n\nBut the greatest mystery is: why did they leave? No traces of war, no evidence of plague, no written record of this city whatsoever. It simply vanished into the folds of history, taking all answers with it. Perhaps this is Machu Picchu's most profound allure — it offers no certainty, only infinite curiosity. It is a doorway to being lost: lost in cloud, lost in time, lost among beautiful mysteries we can never fully understand. To be lost here is itself a way of being found.",
            "latitude": -13.1631,
            "longitude": -72.5450,
            "continent": "South America",
            "country": "Peru"
        ],
        [
            "nameZh": "三星堆遗址",
            "nameEn": "Sanxingdui Ruins",
            "descriptionZh": "三星堆展现了一种与中原文明迥异的、充满奇诡想象力的古代信仰。那些神秘的纵目面具和青铜神树，仿佛来自另一个世界。它提醒我们，我们对过去的认知是多么有限，世界远比我们想象的更加神秘与辽阔。",
            "descriptionEn": "Sanxingdui reveals an ancient faith utterly different from Central Plains civilization, brimming with uncanny imagination. Those mysterious protruding-eyed masks and bronze sacred trees seem to come from another world, reminding us how limited our knowledge of the past truly is.",
            "loreZh": "1986年的一个夏日，四川广汉三星堆的泥土下涌出了另一个世界。两个祭祀坑中出土的文物彻底颠覆了人们对华夏文明的认知——纵目面具的双眼如圆柱般向外凸出十六厘米，仿佛拥有超越常人的视觉；近四米高的青铜神树上栖息着九只太阳鸟，与《山海经》中扶桑树的传说惊人吻合；黄金权杖、金面罩、大量象牙，展现出一个与同时期殷商文明截然不同的古蜀王国。\n\n最令人困惑的是，这个高度发达的文明没有留下任何文字。我们无法知道他们如何称呼自己，无法知道他们信仰什么神灵，无法知道那些怪异的青铜面具究竟用于怎样的仪式。他们的造型如此超越时代、如此不属于任何已知的艺术传统，以至于人们戏称这些文物「仿佛来自另一个星球」。\n\n三星堆的力量在于「未知」本身。它不提供答案，只提出问题——而且每一个问题都指向同一个令人敬畏的事实：在我们自以为了解的历史之下，还埋藏着太多我们一无所知的辉煌。三千年的沉默之后，三星堆向世人揭示了一个真相：世界远比我们想象的更加神秘、更加辽阔、更加不可思议。",
            "loreEn": "On a summer day in 1986, another world surged from beneath the soil at Sanxingdui in Guanghan, Sichuan. The artifacts unearthed from two sacrificial pits completely overturned our understanding of Chinese civilization — protruding-eyed masks with cylindrical pupils jutting out sixteen centimeters, as if possessing superhuman vision; a bronze sacred tree nearly four meters tall with nine sun-birds perched upon it, eerily matching the Fusang Tree legend in the Classic of Mountains and Seas; golden scepters, gold masks, vast quantities of ivory — revealing an ancient Shu kingdom utterly unlike the contemporaneous Shang dynasty.\n\nMost confounding is that this highly advanced civilization left no writing whatsoever. We cannot know what they called themselves, what gods they worshipped, or what rituals those bizarre bronze masks served. Their forms are so far beyond their era, so outside any known artistic tradition, that people half-joke these artifacts 'seem to come from another planet.'\n\nSanxingdui's power lies in the unknown itself. It provides no answers, only questions — and every question points to the same awe-inspiring fact: beneath the history we think we know, there lie buried far too many splendors of which we know nothing. After three thousand years of silence, Sanxingdui reveals a truth: the world is far more mysterious, far more vast, far more incredible than we ever imagined.",
            "latitude": 31.0019,
            "longitude": 104.2028,
            "continent": "Asia",
            "country": "China",
            "region": "Sichuan"
        ],
        [
            "nameZh": "拉帕努伊岛",
            "nameEn": "Rapa Nui",
            "descriptionZh": "在世界最偏远的角落，一群人创造了举世震惊的文明，又因未知原因而衰落。近千座摩艾石像是人类意志最孤绝的表达。它是关于「隔绝」与「创造力」、「辉煌」与「警示」的深刻寓言，引发对文明本质的思考。",
            "descriptionEn": "In the most remote corner of the world, a people created an astonishing civilization that declined for unknown reasons. Nearly a thousand Moai are the most solitary expression of human will — a profound parable of isolation and creativity, glory and warning.",
            "loreZh": "在南太平洋距离最近大陆三千七百公里的地方，有一座面积仅一百六十三平方公里的三角形火山岛。就是在这座极致孤绝的弹丸之地上，拉帕努伊人创造了地球上最令人匪夷所思的文明奇迹——近千座巨大的摩艾石像。\n\n这些石像最高者达十米，重达八十二吨，全部背朝大海、面向岛内。它们不是望向外部世界的瞭望者，而是守护自己子民的祖先之灵。拉帕努伊人相信，祖先的精神力量（mana）寄居在这些石像之中，庇佑着岛上的生灵。\n\n为了雕刻和运输这些巨像，整个文明倾尽了一切——包括岛上最后一棵树。这正是拉帕努伊岛最深刻的悲剧与寓言。一个与世隔绝的小小文明，将所有资源投入到信仰的表达之中，创造了举世震惊的奇迹，却也因此走向了不可逆转的衰落。当最后一棵棕榈树倒下，他们再也无法造船出海、无法获取足够的食物、无法运输新的石像。辉煌与毁灭，竟出自同一种激情。\n\n站在阿胡·汤加里基的十五座摩艾面前，看着它们在太平洋的风中沉默地凝视远方，你会感受到一种近乎窒息的孤独——以及一个穿越时空的叩问：当我们用尽一切去追寻信仰，我们是在接近救赎，还是在接近终结？",
            "loreEn": "In the South Pacific, 3,700 kilometers from the nearest continent, lies a triangular volcanic island of just 163 square kilometers. On this supremely isolated speck of land, the Rapa Nui people created one of Earth's most astonishing civilizational wonders — nearly a thousand colossal Moai statues.\n\nThe tallest reach ten meters and weigh up to eighty-two tons, all facing inland with their backs to the sea. They are not sentinels watching the outside world but ancestral spirits guarding their own people. The Rapa Nui believed that the spiritual power (mana) of their ancestors dwelled within these statues, protecting all life on the island.\n\nTo carve and transport these giants, the entire civilization gave everything it had — including the island's last tree. This is Rapa Nui's most profound tragedy and parable. A small, isolated civilization poured all its resources into expressing its faith, creating a wonder that stunned the world, yet drove itself toward irreversible decline. When the last palm fell, they could no longer build boats, gather enough food, or move new statues. Glory and destruction sprang from the same passion.\n\nStanding before the fifteen Moai at Ahu Tongariki, watching them gaze silently into the distance in the Pacific wind, you feel an almost suffocating loneliness — and a question that echoes across time: when we give everything to pursue our faith, are we approaching salvation, or approaching the end?",
            "latitude": -27.1127,
            "longitude": -109.3497,
            "continent": "South America",
            "country": "Chile"
        ],

        // ═══════════════════════════════════════════
        // 第四类：美学圣迹 (The Aesthetic Wellsprings)
        // ═══════════════════════════════════════════

        [
            "nameZh": "黄山",
            "nameEn": "Mount Huangshan",
            "descriptionZh": "黄山本身就是一幅流动的、立体的中国水墨画。它所代表的不是宗教的崇高，也不是历史的厚重，而是纯粹的、能激发无限创造力的「自然美学」。它是所有文人墨客和艺术家的精神归宿，是属于创造者的归途。",
            "descriptionEn": "Mount Huangshan is itself a flowing, three-dimensional Chinese ink painting. It represents neither religious sublimity nor historical gravitas, but pure natural aesthetics that ignite infinite creativity — the spiritual home of all poets, scholars, and artists, the homecoming of creators.",
            "loreZh": "「五岳归来不看山，黄山归来不看岳。」明代旅行家徐霞客的这句感叹，道出了黄山在中国自然美学中至高无上的地位。这里没有帝王的封禅、没有宗教的殿堂、没有远古的仪式——黄山的「神圣」完全来自于自然本身的创造力。\n\n七十二座奇峰在云雾中时隐时现，如同一卷正在缓缓展开的水墨长卷。迎客松扎根于悬崖绝壁的岩缝之中，以千年不屈的姿态向来者伸出苍劲的臂膀——它是生命力最优雅的象征。云海在峰谷之间涌动翻腾，当阳光穿透云层，整座山脉被染成一片流动的金色，让你分不清是在看山，还是在看一场大自然导演的光影戏剧。温泉从花岗岩的裂隙中涌出，滋养着苔藓、灵芝和千种奇花异草。\n\n黄山代表的是一种纯粹的「意境」——中国美学中最核心也最难以言传的概念。它不是具体的美景，而是景象在心灵中激发的那份共鸣与感动。千百年来，李白、王维、石涛、渐江……无数文人墨客和画家在此获得灵感的启示，将黄山的神韵化为诗篇与画作，再传递给后世千万颗渴望美的心灵。来到黄山，你寻找的不是风景，而是那个在美面前被深深触动、重新找回创造力的自己。",
            "loreEn": "'Having seen the Five Sacred Mountains, one need not see other mountains; having seen Huangshan, one need not see the Five Sacred Mountains.' This exclamation by the Ming dynasty traveler Xu Xiake speaks to Huangshan's supreme place in Chinese natural aesthetics. Here there are no imperial sacrifices, no religious temples, no ancient rituals — Huangshan's sacredness comes entirely from nature's own creativity.\n\nSeventy-two fantastical peaks appear and vanish in the mists like a slowly unrolling ink scroll. The Welcoming Pine, rooted in a cliff-face crevice, extends its weathered arms to visitors with a thousand years of unyielding grace — the most elegant symbol of vitality. Seas of clouds surge between peaks and valleys; when sunlight pierces through, the entire mountain range is dyed a flowing gold, until you cannot tell whether you are viewing a mountain or a play of light and shadow directed by nature itself. Hot springs well up from granite fissures, nourishing moss, lingzhi, and a thousand exotic flowers.\n\nHuangshan represents pure 'yijing' — the most essential yet most ineffable concept in Chinese aesthetics. Not the concrete beauty itself, but the resonance and emotion it awakens in the soul. For centuries, poets like Li Bai, painters like Shi Tao and Jianjiang have found revelation here, transmuting Huangshan's spirit into verse and brush. Coming to Huangshan, you seek not scenery, but the self that is deeply moved before beauty and rediscovers the power to create.",
            "latitude": 30.1307,
            "longitude": 118.1679,
            "continent": "Asia",
            "country": "China",
            "region": "Anhui"
        ],
        [
            "nameZh": "贝加尔湖",
            "nameEn": "Lake Baikal",
            "descriptionZh": "贝加尔湖是地球上最古老、最深的淡水湖，象征着原始、纯净和深邃的生命本源。蒙古人称它为「圣海」，西伯利亚萨满教的根源在此。它的蓝冰和清澈湖水拥有净化心灵的强大能量，是映照灵魂的最纯净之镜。",
            "descriptionEn": "Lake Baikal is the oldest and deepest freshwater lake on Earth, symbolizing primal purity and the profound origin of life. Mongolians call it the 'Sacred Sea,' and Siberian shamanism finds its roots here — its blue ice and crystal waters possess powerful energy to purify the soul.",
            "loreZh": "两千五百万年——当恐龙灭绝后的新世界正在缓慢成型时，贝加尔湖已经在西伯利亚的大地上睁开了它深邃的蓝色眼睛。它是地球上最古老的湖泊，也是最深的湖泊——最深处达一千六百四十二米，蕴含着全球五分之一的淡水。如果将地球上所有的河流同时注入一个空的贝加尔湖，需要整整一年才能将其填满。\n\n蒙古人称它为「圣海」，布里亚特萨满视它为通往灵界的门户。在萨满教的宇宙观中，贝加尔湖是大地的灵魂之眼，它的水是世界上最纯净的眼泪，能够洗去一切污浊与迷障。\n\n每年入冬，湖面凝结成一片晶莹剔透的蓝冰，在冰层的裂缝和气泡之间，深邃的蓝光从湖底向上透射，仿佛大地本身正在发光——那是一种只有在这里才能看到的、介于翡翠与蓝宝石之间的神秘光泽。\n\n贝加尔湖的纯净不仅是物理意义上的。在这片远离一切喧嚣的冰原之上，时间被稀释、声音被吸收、思绪被澄清。你看到的只有冰、天空和无尽的地平线——所有多余的东西都被过滤殆尽。它是大地最深处的一滴泪，也是映照灵魂的最纯净的一面镜子。在它面前，你无法伪装，只能以最真实的面目与自己相见。",
            "loreEn": "Twenty-five million years — when the new world after the dinosaurs' extinction was still slowly taking shape, Lake Baikal had already opened its deep blue eye upon the Siberian earth. It is the oldest lake on the planet and the deepest — reaching 1,642 meters at its nadir, holding one-fifth of the world's fresh water. If every river on Earth were simultaneously poured into an empty Baikal, it would take an entire year to fill.\n\nMongolians call it the Sacred Sea; Buryat shamans regard it as a gateway to the spirit realm. In shamanic cosmology, Lake Baikal is the soul-eye of the earth, its water the purest tear in the world, capable of washing away all impurity and illusion.\n\nEach winter, the lake freezes into crystalline blue ice. Between cracks and frozen bubbles, deep blue light radiates upward from the lake floor, as if the earth itself is glowing — a mysterious luster found nowhere else, somewhere between jade and sapphire.\n\nBaikal's purity is more than physical. On this ice field far from all noise, time is diluted, sound is absorbed, thoughts are clarified. All you see is ice, sky, and an endless horizon — everything superfluous filtered away. It is the deepest tear of the earth and the purest mirror of the soul. Before it, you cannot pretend — you can only meet yourself in your most authentic form.",
            "latitude": 53.5587,
            "longitude": 108.1650,
            "continent": "Asia",
            "country": "Russia",
            "region": "Siberia"
        ],

        // ═══════════════════════════════════════════
        // 极境圣迹 (The Polar Sanctuaries)
        // ═══════════════════════════════════════════

        [
            "nameZh": "北极圈",
            "nameEn": "The Arctic Circle",
            "descriptionZh": "北极是地球与宇宙能量交换最壮丽的剧场。极光是太阳风与地球磁场共舞的视觉奇迹，北极星是数千年来为迷途者指引方向的永恒坐标。它代表着「指引」与「连接」的能量——引导我们思考何为自己永不改变的北极星。",
            "descriptionEn": "The Arctic is the most magnificent theater of energy exchange between Earth and cosmos. The aurora is a visual miracle of solar wind dancing with the magnetosphere; Polaris has guided the lost for millennia. It represents the energy of guidance and connection.",
            "loreZh": "当你足够靠近这颗星球的顶端，天空便开始表演它最壮丽的魔术。极光——太阳风中的带电粒子与地球磁场碰撞后产生的发光现象——在北极圈的夜空中化为流动的绿色帷幕、紫色丝带和粉红色的光焰，仿佛宇宙正以最绚烂的方式与大地对话。因纽特人相信极光是亡灵在天空中踢球时发出的光芒，维京人则认为那是女武神铠甲的反光。无论哪种解读，都在表达同一种直觉：那道光，连接着此世与彼岸。\n\n在极光之上，北极星稳定地悬挂在天穹的正中——数千年来，它是航海者、游牧者和所有迷途之人在黑暗中最忠实的向导。当一切都在变化，当罗盘开始失灵，当你不知道该往何处去，只要抬头，北极星永远在那里，沉默、笃定、不曾移动。它不告诉你该去哪里，只告诉你「北」在哪里——剩下的方向，由你自己决定。\n\n在极昼与极夜交替的世界里，时间的意义被彻底重写。连续数月不落的太阳，或者连续数月不升的太阳，颠覆着你对「一天」的基本认知。在这里，你会被迫去思考一些平时从不会想的问题：如果没有日出和日落来切割时间，「今天」和「明天」还有区别吗？当外部的坐标全部消失，你内心的方向感还在吗？北极圈的终极追问是：在人生的迷雾中，什么是你永不改变的「北极星」？",
            "loreEn": "When you draw close enough to the crown of the planet, the sky begins its most magnificent magic. The aurora — light born from the collision of charged solar particles with Earth's magnetic field — transforms the Arctic night into flowing green curtains, purple ribbons, and pink flames of light, as if the cosmos is conversing with the earth in its most radiant language. The Inuit believe the aurora is the glow of spirits playing ball in the sky; the Vikings saw it as the reflection of Valkyrie armor. Every interpretation expresses the same intuition: that light connects this world to the beyond.\n\nAbove the aurora, Polaris hangs steady at the center of the celestial dome — for thousands of years, the most faithful guide for sailors, nomads, and all who are lost in the dark. When everything changes, when the compass fails, when you don't know where to go, just look up. Polaris is always there — silent, certain, unmoved. It doesn't tell you where to go, only where north is. The rest of the direction is yours to decide.\n\nIn a world of alternating midnight sun and polar night, the meaning of time is completely rewritten. Months of unending sun or months of unending darkness upend your basic understanding of 'a day.' Here, you are forced to confront questions you never normally ask: without sunrise and sunset to divide time, is there still a difference between today and tomorrow? When all external coordinates vanish, does your inner sense of direction survive? The Arctic's ultimate question is: in the fog of life, what is your unchanging North Star?",
            "latitude": 78.2306,
            "longitude": 15.6469,
            "continent": "Arctic",
            "country": "Svalbard, Norway"
        ],
        [
            "nameZh": "南极大陆",
            "nameEn": "Antarctica",
            "descriptionZh": "南极是地球上最接近「初始」状态的地方，是终极的「寂静之所」。它剥离了所有文明的噪音和色彩，只剩下纯粹的白。在这片极致寂静中，唯一能听到的是你内心的回响，引导你思考最本初的「我」究竟是什么。",
            "descriptionEn": "Antarctica is the closest place on Earth to a primordial state, the ultimate sanctuary of silence. It strips away all civilization's noise and color, leaving only pure white. In this extreme stillness, the only sound is the echo within, guiding you to ask: what is the most primordial self?",
            "loreZh": "南极大陆是地球上最后一片被人类发现的大陆，也是唯一没有原住民、没有国界、不属于任何国家的土地。厚达两千七百米的冰盖之下，封存着数百万年的气候记忆——每一层冰芯都是一页地球的日记，记录着远古的大气成分、火山喷发的灰烬和太阳活动的痕迹。这里是地球的时间胶囊，也是它最安静的图书馆。\n\n南极的核心体验是「减法」。在这片占地球面积十分之一的纯白大陆上，没有树木、没有建筑、没有道路、没有任何人造的标记。色彩被简化到只剩下白色与蓝色的无穷变奏，声音被压缩到只剩下风的呼啸和冰层偶尔发出的深沉裂响。你的视野中没有任何可以锚定「远近」和「大小」的参照物，空间感被彻底重置——一座冰山可能在五十公里之外，也可能就在眼前。\n\n这种极致的「空」具有强大的净化力量。当所有外在的信息、噪音、身份标签、社会期待都被这片白色过滤殆尽，你终于有机会面对那个一直被掩盖在层层包装之下的问题：当褪去一切角色和面具之后，那个最本初、最纯粹的「我」，究竟是什么模样？南极不会给你答案——它只是为你创造了一个足够安静的空间，让你终于能够听见自己。",
            "loreEn": "Antarctica is the last continent discovered by humanity, and the only land with no indigenous people, no borders, belonging to no nation. Beneath ice sheets over 2,700 meters thick, millions of years of climate memory are sealed — each ice core is a page of Earth's diary, recording ancient atmospheric composition, volcanic ash, and traces of solar activity. This is Earth's time capsule and its quietest library.\n\nAntarctica's core experience is subtraction. On this pure white continent covering one-tenth of Earth's surface, there are no trees, no buildings, no roads, no human markers whatsoever. Color is reduced to infinite variations of white and blue; sound is compressed to the howl of wind and the occasional deep crack of ice. Your field of vision contains no reference points for distance or scale — an iceberg might be fifty kilometers away or right before you.\n\nThis extreme emptiness possesses powerful purifying force. When all external information, noise, identity labels, and social expectations are filtered away by this whiteness, you finally have the chance to face the question that has always been buried beneath layers of packaging: when all roles and masks are stripped away, what does the most primordial, most pure 'I' look like? Antarctica does not give you the answer — it merely creates a space quiet enough for you to finally hear yourself.",
            "latitude": -90.0,
            "longitude": 0.0,
            "continent": "Antarctica",
            "country": "International Territory"
        ]
    ]

    // MARK: - Tier 2 地脉节点

    static let leyNodes: [[String: Any]] = [
        [
            "nameZh": "西湖",
            "nameEn": "West Lake",
            "descriptionZh": "人间天堂，千年诗意的栖居",
            "descriptionEn": "Paradise on earth, a millennium of poetic dwelling",
            "loreZh": "西湖是江南灵气的凝聚之地。苏堤、断桥、雷峰塔，每一处都承载着无数文人墨客的情思。漫步湖畔，你会发现自己不知不觉已融入这幅水墨画中。",
            "loreEn": "West Lake is where the spirit of Jiangnan converges. Su Causeway, Broken Bridge, Leifeng Pagoda — each carries the emotions of countless poets and scholars.",
            "latitude": 30.2590,
            "longitude": 120.1388,
            "continent": "Asia",
            "country": "China",
            "region": "Hangzhou"
        ],
        [
            "nameZh": "中央公园",
            "nameEn": "Central Park",
            "descriptionZh": "都市绿洲，钢铁森林中的呼吸",
            "descriptionEn": "Urban oasis, breathing space in the concrete jungle",
            "loreZh": "在曼哈顿的心脏地带，中央公园是这座不夜城最珍贵的喘息之地。无论季节如何更迭，这里始终是纽约人寻找内心平静的圣地。",
            "loreEn": "In the heart of Manhattan, Central Park is this city's most precious breathing space. Regardless of the season, it remains the sanctuary where New Yorkers find inner peace.",
            "latitude": 40.7829,
            "longitude": -73.9654,
            "continent": "North America",
            "country": "USA",
            "region": "New York"
        ],
        [
            "nameZh": "洱海",
            "nameEn": "Erhai Lake",
            "descriptionZh": "苍山下的明珠，风花雪月的故乡",
            "descriptionEn": "Pearl beneath the Cangshan Mountains, home of wind, flowers, snow and moon",
            "loreZh": "洱海不是海，却比海更能安抚旅人的心。苍山十九峰映入湖面，白族的歌声随风飘来。在这里，时间会变慢，心会变得柔软。",
            "loreEn": "Erhai is not a sea, yet it soothes the traveler's heart more than any ocean. Nineteen peaks of Cangshan reflect upon its surface, Bai folk songs drift on the wind. Here, time slows and hearts soften.",
            "latitude": 25.8000,
            "longitude": 100.1800,
            "continent": "Asia",
            "country": "China",
            "region": "Dali"
        ],
        [
            "nameZh": "塞多纳",
            "nameEn": "Sedona",
            "descriptionZh": "红岩圣地，地球能量漩涡之城",
            "descriptionEn": "Red rock sanctuary, city of Earth's energy vortexes",
            "loreZh": "塞多纳的红岩被认为是地球上最强烈的能量漩涡所在地之一。无数寻求灵性觉醒的旅人来到这里，在壮丽的红色峡谷中找到了与大地的深层连接。",
            "loreEn": "Sedona's red rocks are believed to be among the most powerful energy vortex sites on Earth. Countless seekers of spiritual awakening come here, finding deep connection with the land amid its magnificent red canyons.",
            "latitude": 34.8697,
            "longitude": -111.7610,
            "continent": "North America",
            "country": "USA",
            "region": "Arizona"
        ]
    ]

    // MARK: - Helper

    private static func createSite(from data: [String: Any], tier: SiteTier) -> SacredSite {
        let site = SacredSite(
            tier: tier,
            nameZh: data["nameZh"] as? String ?? "",
            nameEn: data["nameEn"] as? String ?? ""
        )
        site.descriptionZh = data["descriptionZh"] as? String ?? ""
        site.descriptionEn = data["descriptionEn"] as? String ?? ""
        site.loreZh = data["loreZh"] as? String ?? ""
        site.loreEn = data["loreEn"] as? String ?? ""
        site.latitude = data["latitude"] as? Double ?? 0
        site.longitude = data["longitude"] as? Double ?? 0
        site.continent = data["continent"] as? String ?? ""
        site.country = data["country"] as? String ?? ""
        site.region = data["region"] as? String
        site.imageUrl = data["imageUrl"] as? String
        return site
    }
}
