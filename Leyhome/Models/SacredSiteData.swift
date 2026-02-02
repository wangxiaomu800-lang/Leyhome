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

    // MARK: - Tier 1 源点圣迹

    static let primalSites: [[String: Any]] = [
        [
            "nameZh": "吉萨金字塔",
            "nameEn": "Great Pyramid of Giza",
            "descriptionZh": "地球主脉的心脏，古老文明的永恒见证",
            "descriptionEn": "The heart of Earth's main ley line, eternal witness of ancient civilization",
            "loreZh": "四千年来，金字塔默默矗立于尼罗河畔，它不仅是法老的安息之所，更是地球能量网络最重要的枢纽之一。站在它脚下，你能感受到时间的厚重与宇宙的浩瀚交织在一起。",
            "loreEn": "For four millennia, the pyramids have stood silently by the Nile. More than a pharaoh's resting place, they are one of the most crucial hubs in Earth's energy network. Standing at their base, you can feel the weight of time intertwining with the vastness of the universe.",
            "latitude": 29.9792,
            "longitude": 31.1342,
            "continent": "Africa",
            "country": "Egypt"
        ],
        [
            "nameZh": "马丘比丘",
            "nameEn": "Machu Picchu",
            "descriptionZh": "云端之城，印加帝国的精神圣殿",
            "descriptionEn": "City in the clouds, spiritual sanctuary of the Inca Empire",
            "loreZh": "隐匿于安第斯山脉的云雾之中，马丘比丘承载着印加文明对宇宙的理解。这里的每一块石头都经过精心打磨，与星辰的轨迹完美呼应。攀登至此，你将完成一次穿越时空的朝圣。",
            "loreEn": "Hidden in the mists of the Andes, Machu Picchu embodies the Inca understanding of the cosmos. Every stone here is precisely crafted, perfectly aligned with the trajectories of stars. Climbing here, you complete a pilgrimage through time and space.",
            "latitude": -13.1631,
            "longitude": -72.5450,
            "continent": "South America",
            "country": "Peru"
        ],
        [
            "nameZh": "巨石阵",
            "nameEn": "Stonehenge",
            "descriptionZh": "史前巨石圈，天地交汇的神秘门户",
            "descriptionEn": "Prehistoric stone circle, a mysterious gateway where heaven and earth meet",
            "loreZh": "五千年前的先民，用超乎想象的智慧竖起这些巨石。每年夏至日出，阳光穿过石门洒向祭坛，天地之间的能量在此刻达到顶峰。这是一个与宇宙对话的地方。",
            "loreEn": "Five thousand years ago, our ancestors erected these massive stones with unimaginable wisdom. Every summer solstice, sunrise light passes through the stone gates onto the altar, when the energy between heaven and earth reaches its peak.",
            "latitude": 51.1789,
            "longitude": -1.8262,
            "continent": "Europe",
            "country": "United Kingdom"
        ],
        [
            "nameZh": "泰山",
            "nameEn": "Mount Tai",
            "descriptionZh": "五岳之首，帝王封禅之地",
            "descriptionEn": "Chief of the Five Sacred Mountains, where emperors communed with heaven",
            "loreZh": "自古以来，泰山便是中华民族精神的象征。七十二位帝王曾在此封禅，祈求天地庇佑。登临泰山之巅，云海翻涌，仿佛触手可及天庭。这里的每一步，都是与先人的对话。",
            "loreEn": "Since ancient times, Mount Tai has been a symbol of the Chinese spirit. Seventy-two emperors performed the Feng and Shan sacrifices here. At the summit, clouds surge like seas, as if heaven is within reach.",
            "latitude": 36.2541,
            "longitude": 117.1010,
            "continent": "Asia",
            "country": "China"
        ],
        [
            "nameZh": "富士山",
            "nameEn": "Mount Fuji",
            "descriptionZh": "日本圣山，自然与精神的完美统一",
            "descriptionEn": "Japan's sacred mountain, perfect unity of nature and spirit",
            "loreZh": "富士山是日本人心中永恒的精神家园。无论是远眺还是攀登，它都能给予你内心的宁静与力量。那完美的圆锥形轮廓，仿佛是大地与天空之间最优雅的连接。",
            "loreEn": "Mount Fuji is the eternal spiritual home in the hearts of the Japanese. Whether viewed from afar or climbed, it bestows inner peace and strength. Its perfect conical silhouette seems like the most elegant connection between earth and sky.",
            "latitude": 35.3606,
            "longitude": 138.7274,
            "continent": "Asia",
            "country": "Japan"
        ],
        // --- 中国 ---
        [
            "nameZh": "冈仁波齐",
            "nameEn": "Mount Kailash",
            "descriptionZh": "世界轴心，万法归宗，信仰之源",
            "descriptionEn": "Axis Mundi, the origin of all faiths, source of belief",
            "loreZh": "冈仁波齐被四大宗教——印度教、藏传佛教、耆那教与苯教——共尊为世界的中心。它是传说中须弥山的化身，是宇宙的轴心（Axis Mundi）。千百年来，无数朝圣者以身体丈量这座圣山，在转山的苦行中寻求灵魂的洗涤。冰雪覆顶的金字塔形山峰，沉默地注视着一切，万法归宗，归于此峰。",
            "loreEn": "Mount Kailash is revered as the center of the world by four religions — Hinduism, Tibetan Buddhism, Jainism, and Bön. It is believed to be the manifestation of Mount Meru, the Axis Mundi of the cosmos. For millennia, countless pilgrims have measured this sacred mountain with their bodies, seeking purification of the soul through the arduous kora circumambulation. The snow-capped pyramidal peak silently watches over all — where all paths converge, all dharma returns.",
            "latitude": 31.0672,
            "longitude": 81.3119,
            "continent": "Asia",
            "country": "China",
            "region": "Tibet"
        ],
        [
            "nameZh": "布达拉宫",
            "nameEn": "Potala Palace",
            "descriptionZh": "雪域圣殿，信仰之心，高原之光",
            "descriptionEn": "Sacred palace of the snow land, heart of faith, light of the plateau",
            "loreZh": "布达拉宫矗立于拉萨红山之巅，是藏传佛教信仰的至高象征。相传它是观音菩萨的道场，历代达赖喇嘛在此传承法脉。红白相间的宫墙如同一座通往天界的阶梯，在海拔三千七百米的高原之上，它是离天最近的圣殿。每一位踏入其中的旅者，都能感受到千年信仰凝聚而成的庄严力量。",
            "loreEn": "The Potala Palace rises atop Red Mountain in Lhasa, the supreme symbol of Tibetan Buddhist faith. Legend holds it as the earthly abode of Avalokiteśvara, where successive Dalai Lamas transmitted the dharma lineage. Its red-and-white walls ascend like a stairway to heaven, and at 3,700 meters above sea level, it is the temple closest to the sky. Every traveler who enters can feel the solemn power accumulated from a millennium of devotion.",
            "latitude": 29.6577,
            "longitude": 91.1170,
            "continent": "Asia",
            "country": "China",
            "region": "Tibet"
        ],
        [
            "nameZh": "嵩山",
            "nameEn": "Mount Songshan",
            "descriptionZh": "天地之中，禅武合一，中岳根脉",
            "descriptionEn": "Center of heaven and earth, where Zen meets martial arts",
            "loreZh": "嵩山居五岳之中，自古被尊为天地之中。少林寺在此开创禅武合一的传统，达摩面壁九年，将佛法与武学融为一体。嵩阳书院的晨钟暮鼓，回荡着千年儒学的智慧。这座山不仅是中华武术的摇篮，更是儒、释、道三教交汇的精神枢纽。登临嵩山，你将触摸到中原文明最深处的根脉。",
            "loreEn": "Mount Songshan stands at the center of the Five Sacred Mountains, venerated since antiquity as the center of heaven and earth. The Shaolin Temple founded the tradition of uniting Zen Buddhism with martial arts here, where Bodhidharma meditated facing a wall for nine years, fusing dharma with kung fu. The bells of Songyang Academy echo with a millennium of Confucian wisdom. This mountain is not only the cradle of Chinese martial arts but the spiritual nexus where Confucianism, Buddhism, and Taoism converge.",
            "latitude": 34.4844,
            "longitude": 113.0390,
            "continent": "Asia",
            "country": "China",
            "region": "Henan"
        ],
        [
            "nameZh": "三星堆遗址",
            "nameEn": "Sanxingdui Ruins",
            "descriptionZh": "失落的古蜀文明，颠覆认知的神秘遗产",
            "descriptionEn": "Lost civilization of ancient Shu, a heritage that defies understanding",
            "loreZh": "三星堆的出土彻底颠覆了人们对华夏文明的认知。那些纵目面具、青铜神树、黄金权杖，展现出一个与中原截然不同的古蜀王国。它们的造型如此超越时代，仿佛来自另一个维度的信息。三千年的沉默之后，三星堆向世人揭示了一个真相：在这片土地上，曾有过远比我们想象更辉煌、更神秘的文明。",
            "loreEn": "The discoveries at Sanxingdui completely overturned our understanding of Chinese civilization. The protruding-eyed masks, bronze sacred trees, and golden scepters reveal an ancient Shu kingdom utterly different from the Central Plains. Their forms are so far beyond their era, as if carrying information from another dimension. After three thousand years of silence, Sanxingdui reveals a truth: on this land, there once flourished a civilization far more glorious and mysterious than we ever imagined.",
            "latitude": 31.0019,
            "longitude": 104.2028,
            "continent": "Asia",
            "country": "China",
            "region": "Sichuan"
        ],
        [
            "nameZh": "武当山",
            "nameEn": "Wudang Mountains",
            "descriptionZh": "道教圣地，太极之源，仙山福地",
            "descriptionEn": "Sacred Taoist mountain, birthplace of Tai Chi, blessed immortal land",
            "loreZh": "武当山是道教第一圣地，传说中真武大帝修炼飞升之所。张三丰在此创立太极拳，将道家的阴阳哲学化为行云流水般的拳法。金顶的紫金城凌驾于群峰之上，云雾缭绕时，宛如天上宫阙。在这里，人与自然的界限变得模糊，呼吸之间便是天人合一的修行。",
            "loreEn": "Wudang Mountains are the foremost sacred site of Taoism, where legend says the deity Zhenwu cultivated and ascended to immortality. Zhang Sanfeng created Tai Chi here, transforming Taoist philosophy of yin and yang into a martial art flowing like clouds and water. The Golden Summit's Purple Cloud Palace hovers above the peaks, wreathed in mist like a celestial palace. Here, the boundary between human and nature dissolves — every breath becomes a practice of unity with heaven.",
            "latitude": 32.4002,
            "longitude": 111.0048,
            "continent": "Asia",
            "country": "China",
            "region": "Hubei"
        ],
        // --- 世界 ---
        [
            "nameZh": "哥贝克力石阵",
            "nameEn": "Göbekli Tepe",
            "descriptionZh": "人类最古老的圣殿，改写文明起源",
            "descriptionEn": "Humanity's oldest temple, rewriting the origin of civilization",
            "loreZh": "哥贝克力石阵比金字塔早七千年，比巨石阵早六千年。一万两千年前，当人类还是采集狩猎者时，便已在此竖起巨大的T形石柱，雕刻着神秘的动物图腾。它颠覆了'先有农业，后有文明'的理论——也许是信仰与仪式，而非面包，催生了人类最初的聚落。这是已知最古老的人类圣殿，文明的真正零点。",
            "loreEn": "Göbekli Tepe predates the pyramids by seven thousand years, Stonehenge by six thousand. Twelve thousand years ago, when humans were still hunter-gatherers, they erected massive T-shaped stone pillars here, carved with mysterious animal totems. It overturns the theory that 'agriculture preceded civilization' — perhaps it was faith and ritual, not bread, that gave birth to humanity's first settlements. This is the oldest known human temple, the true zero point of civilization.",
            "latitude": 37.2233,
            "longitude": 38.9225,
            "continent": "Asia",
            "country": "Turkey",
            "region": "Şanlıurfa"
        ],
        [
            "nameZh": "德尔斐",
            "nameEn": "Delphi",
            "descriptionZh": "世界的肚脐，阿波罗神谕之地",
            "descriptionEn": "Navel of the world, seat of Apollo's Oracle",
            "loreZh": "古希腊人相信德尔斐是世界的中心——宙斯放出两只鹰分飞天涯，它们在德尔斐交汇，此处便是大地的肚脐（Omphalos）。阿波罗神殿中的女祭司皮提亚在此传达神谕，左右着希腊世界的战争与和平。帕纳索斯山的岩壁间，至今仍回荡着'认识你自己'的古老训诫。这是理性与神性交织的圣地。",
            "loreEn": "The ancient Greeks believed Delphi was the center of the world — Zeus released two eagles from opposite ends of the earth, and they met at Delphi, marking it as the Omphalos, the navel of the world. The priestess Pythia delivered Apollo's oracles here, shaping the wars and peace of the Greek world. Among the cliffs of Mount Parnassus, the ancient admonition 'Know Thyself' still echoes. This is a sacred site where reason and divinity intertwine.",
            "latitude": 38.4824,
            "longitude": 22.5010,
            "continent": "Europe",
            "country": "Greece"
        ],
        [
            "nameZh": "乌鲁鲁",
            "nameEn": "Uluru",
            "descriptionZh": "大地的心脏，原住民万年梦境之石",
            "descriptionEn": "Heart of the earth, Aboriginal dreamtime stone of ten thousand years",
            "loreZh": "乌鲁鲁是澳大利亚原住民阿南古人最神圣的圣地，在他们的创世神话'梦境时代'中，祖先精灵在此塑造了世界。这块巨大的砂岩巨石在日出日落时变幻着赤红、橙金、深紫的色彩，仿佛大地在呼吸。它是地球上最古老的连续信仰体系——超过四万年的精神传承——的核心标志。",
            "loreEn": "Uluru is the most sacred site for the Anangu Aboriginal people. In their creation mythology of the Dreamtime, ancestral spirits shaped the world here. This immense sandstone monolith transforms through crimson, golden-orange, and deep purple at sunrise and sunset, as if the earth itself is breathing. It is the central marker of the oldest continuous belief system on Earth — a spiritual heritage spanning over forty thousand years.",
            "latitude": -25.3444,
            "longitude": 131.0369,
            "continent": "Oceania",
            "country": "Australia",
            "region": "Northern Territory"
        ],
        [
            "nameZh": "拉帕努伊岛",
            "nameEn": "Rapa Nui (Easter Island)",
            "descriptionZh": "世界尽头的守望者，摩艾的永恒凝视",
            "descriptionEn": "Sentinels at the world's end, the eternal gaze of the Moai",
            "loreZh": "在太平洋最孤独的角落，拉帕努伊岛上近千座摩艾石像背朝大海，守望着岛上的子民。这些巨大的石脸究竟承载着怎样的信仰与执念？一个弹丸小岛上的文明，倾尽所有资源雕刻这些巨像，仿佛在向无垠的宇宙发出一个信号：我们曾在此存在。这是人类意志最极致、最孤绝的表达。",
            "loreEn": "In the loneliest corner of the Pacific Ocean, nearly a thousand Moai statues on Rapa Nui stand with their backs to the sea, watching over the island's people. What faith and obsession do these colossal stone faces carry? A civilization on a tiny island poured all its resources into carving these giants, as if sending a signal to the infinite cosmos: we were here. This is the most extreme and solitary expression of human will.",
            "latitude": -27.1127,
            "longitude": -109.3497,
            "continent": "South America",
            "country": "Chile"
        ],
        [
            "nameZh": "特奥蒂瓦坎",
            "nameEn": "Teotihuacan",
            "descriptionZh": "众神之城，太阳与月亮金字塔的亡者大道",
            "descriptionEn": "City of the Gods, Avenue of the Dead beneath the Sun and Moon Pyramids",
            "loreZh": "特奥蒂瓦坎是美洲最大的古代城市遗址，阿兹特克人发现它时已是废墟，震撼之余称之为'众神诞生之地'。亡者大道两侧，太阳金字塔和月亮金字塔遥遥相对，整座城市的布局精确对应着天体运行的轨迹。是谁建造了这座城市？它为何被遗弃？这些谜团至今无解，但站在金字塔顶，你能感受到一种超越时间的宏大叙事。",
            "loreEn": "Teotihuacan is the largest ancient city site in the Americas. When the Aztecs discovered it already in ruins, they were so awestruck they called it 'the place where the gods were born.' Along the Avenue of the Dead, the Pyramid of the Sun and Pyramid of the Moon face each other, the entire city's layout precisely corresponding to celestial trajectories. Who built this city? Why was it abandoned? These mysteries remain unsolved, but standing atop the pyramids, you can feel a grand narrative that transcends time.",
            "latitude": 19.6925,
            "longitude": -98.8438,
            "continent": "North America",
            "country": "Mexico"
        ],
        [
            "nameZh": "瓦拉纳西",
            "nameEn": "Varanasi",
            "descriptionZh": "恒河圣城，生死轮回的永恒渡口",
            "descriptionEn": "Holy city on the Ganges, the eternal crossing of life and death",
            "loreZh": "瓦拉纳西是世界上最古老的持续有人居住的城市之一，印度教徒相信在此死去便能跳出轮回、获得解脱。恒河岸边，火葬的烟火日夜不息，与清晨祈祷者的吟诵交织在一起。生与死在这里不是对立，而是同一条河流的两岸。走过那些石阶通往河边的ghats，你将亲眼目睹人类面对永恒时最坦然的姿态。",
            "loreEn": "Varanasi is one of the oldest continuously inhabited cities in the world. Hindus believe that dying here liberates the soul from the cycle of reincarnation. On the banks of the Ganges, cremation fires burn day and night, interweaving with the morning chants of the devout. Life and death here are not opposites but two banks of the same river. Walking down the stone ghats to the waterfront, you will witness humanity's most serene posture in the face of eternity.",
            "latitude": 25.3176,
            "longitude": 83.0064,
            "continent": "Asia",
            "country": "India"
        ],
        [
            "nameZh": "巨蛇墩",
            "nameEn": "Serpent Mound",
            "descriptionZh": "北美大地之蛇，古老部族的宇宙图腾",
            "descriptionEn": "Great serpent of North America, cosmic totem of ancient tribes",
            "loreZh": "巨蛇墩是北美最大、最神秘的史前土丘遗迹。从空中俯瞰，一条巨蛇蜿蜒四百余米，张口吞下一颗卵——这是生命、死亡与重生的永恒循环。它的建造者身份至今成谜，但蛇身的曲线精确对应着月球运行的周期。这是大地母亲最宏伟的纹身，是先民用土地本身书写的宇宙密码。",
            "loreEn": "Serpent Mound is the largest and most mysterious prehistoric effigy mound in North America. From above, a great serpent undulates over four hundred meters, its jaws opening to swallow an egg — an eternal cycle of life, death, and rebirth. The identity of its builders remains a mystery, but the serpent's curves precisely correspond to lunar cycles. This is the grandest tattoo on Mother Earth, a cosmic code written by ancient peoples using the land itself.",
            "latitude": 39.0253,
            "longitude": -83.4303,
            "continent": "North America",
            "country": "USA",
            "region": "Ohio"
        ],
        [
            "nameZh": "纽格莱奇墓",
            "nameEn": "Newgrange",
            "descriptionZh": "凯尔特先民的光之圣殿，冬至的奇迹",
            "descriptionEn": "Light temple of Celtic ancestors, miracle of the winter solstice",
            "loreZh": "纽格莱奇墓比金字塔还古老五百年。每年冬至日出，一束阳光会精确地穿过狭长的通道，照亮墓室深处——整整十七分钟的光明，划破一年中最漫长的黑暗。五千年前的建造者，将对光明的渴望与对宇宙的理解，永远铭刻在了这座石头圣殿之中。螺旋纹、菱形纹的巨石雕刻，是欧洲最古老的天文密码。",
            "loreEn": "Newgrange is five hundred years older than the pyramids. Every winter solstice at sunrise, a beam of light passes precisely through its narrow passage to illuminate the inner chamber — seventeen minutes of light piercing the longest darkness of the year. Five thousand years ago, its builders etched their longing for light and understanding of the cosmos forever into this stone temple. The spiral and diamond carvings on its massive stones are Europe's oldest astronomical codes.",
            "latitude": 53.6947,
            "longitude": -6.4754,
            "continent": "Europe",
            "country": "Ireland",
            "region": "County Meath"
        ],
        [
            "nameZh": "耶路撒冷",
            "nameEn": "Jerusalem",
            "descriptionZh": "三教圣城，信仰的交汇点，永恒之城",
            "descriptionEn": "Holy city of three faiths, crossroads of belief, the eternal city",
            "loreZh": "耶路撒冷是犹太教、基督教和伊斯兰教共同的圣城——西墙是犹太人最后的祈祷之地，圣墓教堂是耶稣受难与复活之所，岩石圆顶清真寺是穆罕默德夜行登霄之处。三千年来，无数帝国为它征战，无数信徒为它落泪。在这座城市的每一块古石上，都叠印着人类对神圣最深沉、最炽烈的渴望。",
            "loreEn": "Jerusalem is the shared holy city of Judaism, Christianity, and Islam — the Western Wall is the last place of prayer for Jews, the Church of the Holy Sepulchre marks the crucifixion and resurrection of Jesus, and the Dome of the Rock commemorates Muhammad's Night Journey. For three thousand years, countless empires fought for it, countless believers wept for it. On every ancient stone of this city is imprinted humanity's deepest, most fervent longing for the divine.",
            "latitude": 31.7683,
            "longitude": 35.2137,
            "continent": "Asia",
            "country": "Israel"
        ],
        [
            "nameZh": "贝加尔湖",
            "nameEn": "Lake Baikal",
            "descriptionZh": "西伯利亚蓝眼睛，地球最深的记忆",
            "descriptionEn": "Blue eye of Siberia, the deepest memory of the Earth",
            "loreZh": "贝加尔湖是地球上最古老、最深的淡水湖，拥有两千五百万年的历史，蕴含着全球五分之一的淡水。蒙古人称它为'圣海'，布里亚特萨满视它为通往灵界的门户。冬天，湖面结成晶莹剔透的冰层，裂缝中透出深邃的蓝光，仿佛大地睁开了一只通透的眼睛，凝视着宇宙。它是地球最深处的一滴泪，也是最纯净的一面镜。",
            "loreEn": "Lake Baikal is the oldest and deepest freshwater lake on Earth, with a history of twenty-five million years, holding one-fifth of the world's fresh water. Mongolians call it the 'Sacred Sea,' and Buryat shamans regard it as a gateway to the spirit realm. In winter, the lake freezes into crystalline ice, with deep blue light glowing through its cracks, as if the earth has opened a translucent eye gazing at the cosmos. It is the deepest tear of the earth, and its purest mirror.",
            "latitude": 53.5587,
            "longitude": 108.1650,
            "continent": "Asia",
            "country": "Russia",
            "region": "Siberia"
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
