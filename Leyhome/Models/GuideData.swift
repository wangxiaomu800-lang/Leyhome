//
//  GuideData.swift
//  Leyhome - 地脉归途
//
//  预置先行者/星图数据
//
//  Created on 2026/02/04.
//

import Foundation

struct GuideData {

    // MARK: - 先行者数据

    private static let guides: [[String: Any]] = [
        [
            "name": "林深",
            "titleZh": "正念导师 · 山野行者",
            "titleEn": "Mindfulness Guide · Mountain Walker",
            "bioZh": "二十年山野徒步经验，致力于将正念冥想与户外行走相结合。相信每一步都是与自己的对话，每一座山都是内心的投影。",
            "bioEn": "Twenty years of mountain hiking experience, dedicated to combining mindfulness meditation with outdoor walking. Believes every step is a dialogue with oneself, every mountain a reflection of the inner world.",
            "avatarUrl": "https://example.com/guide1.jpg",
            "tags": ["正念", "徒步", "山野"]
        ],
        [
            "name": "苏晚",
            "titleZh": "城市漫游家 · 摄影师",
            "titleEn": "Urban Wanderer · Photographer",
            "bioZh": "用镜头捕捉城市的诗意角落，擅长在喧嚣中发现宁静。她的每一次漫步都是一次寻找美的旅程。",
            "bioEn": "Capturing poetic corners of cities through her lens, skilled at finding tranquility in chaos. Every stroll she takes is a journey of seeking beauty.",
            "avatarUrl": "https://example.com/guide2.jpg",
            "tags": ["城市", "摄影", "慢生活"]
        ],
        [
            "name": "云归",
            "titleZh": "诗人 · 古道研究者",
            "titleEn": "Poet · Ancient Trail Researcher",
            "bioZh": "研究中国古代驿道与茶马古道多年，用诗歌记录行走中的感悟。每一条古道都是前人留下的密语，等待我们去破译。",
            "bioEn": "Years of research on ancient Chinese postal roads and tea-horse trails, recording walking insights through poetry. Every ancient trail is a cipher left by our ancestors, waiting to be decoded.",
            "avatarUrl": "https://example.com/guide3.jpg",
            "tags": ["古道", "诗歌", "历史"]
        ]
    ]

    // MARK: - 星图数据

    private static let constellations: [[String: Any]] = [
        [
            "guideName": "林深",
            "nameZh": "城市边缘的呼吸",
            "nameEn": "Breathing at the City's Edge",
            "descriptionZh": "在城市与自然的交界处，找到内心的宁静。这条路线带你从繁华走向寂静，从喧嚣回归本真。",
            "descriptionEn": "Find inner peace at the boundary between city and nature. This route takes you from bustle to silence, from chaos back to authenticity.",
            "difficulty": 2,
            "estimatedHours": 3.0,
            "totalDistance": 8.5,
            "isPremium": false,
            "nodes": [
                [
                    "order": 1,
                    "latitude": 39.9042,
                    "longitude": 116.4074,
                    "titleZh": "起点 · 城市的边界",
                    "titleEn": "Starting Point · City's Edge",
                    "contentZh": "站在这里，回望身后的城市。那些高楼、车流、霓虹——它们构成了我们日常的背景音。但现在，让我们暂时按下静音键。深呼吸，准备好了吗？",
                    "contentEn": "Stand here, look back at the city behind you. Those buildings, traffic, neon lights—they form the background noise of our daily lives. But now, let's press the mute button. Take a deep breath. Are you ready?",
                    "audioUrl": "https://example.com/audio1.mp3"
                ],
                [
                    "order": 2,
                    "latitude": 39.9142,
                    "longitude": 116.4174,
                    "titleZh": "林间小径",
                    "titleEn": "Forest Path",
                    "contentZh": "当树叶开始遮蔽天空，脚下的路变得柔软，你会发现自己的呼吸也随之放缓。不要急着赶路，让每一步都落在当下。",
                    "contentEn": "When leaves begin to cover the sky and the path underfoot softens, you'll find your breathing slows down too. Don't rush. Let every step land in the present moment.",
                    "audioUrl": "https://example.com/audio2.mp3"
                ],
                [
                    "order": 3,
                    "latitude": 39.9242,
                    "longitude": 116.4274,
                    "titleZh": "终点 · 山顶的风",
                    "titleEn": "End Point · Wind at the Summit",
                    "contentZh": "站在这里，风从四面八方吹来。闭上眼睛，感受它穿过你的身体。你不是在对抗风，而是成为风的一部分。这就是归途——回到最初的、最简单的自己。",
                    "contentEn": "Standing here, wind blows from all directions. Close your eyes, feel it pass through your body. You're not fighting the wind—you're becoming part of it. This is the return journey—back to the original, simplest self.",
                    "audioUrl": "https://example.com/audio3.mp3"
                ]
            ]
        ],
        [
            "guideName": "苏晚",
            "nameZh": "老城巷陌的光影",
            "nameEn": "Light and Shadow in Old Town Alleys",
            "descriptionZh": "在老城的小巷中穿行，用眼睛捕捉被时间遗忘的美好。这不仅是一次行走，更是一次与城市记忆的对话。",
            "descriptionEn": "Wander through old town alleys, capturing beauty forgotten by time. This is not just a walk, but a dialogue with the city's memory.",
            "difficulty": 1,
            "estimatedHours": 2.0,
            "totalDistance": 4.2,
            "isPremium": false,
            "nodes": [
                [
                    "order": 1,
                    "latitude": 39.9342,
                    "longitude": 116.3974,
                    "titleZh": "晨光中的老墙",
                    "titleEn": "Old Wall in Morning Light",
                    "contentZh": "看这面斑驳的老墙，阳光在上面画出了时间的年轮。那些裂缝、青苔、褪色的标语——每一处痕迹都是一个故事的开端。",
                    "contentEn": "Look at this mottled old wall, sunlight painting rings of time upon it. Those cracks, moss, faded slogans—every mark is the beginning of a story.",
                    "audioUrl": "https://example.com/audio4.mp3"
                ]
            ]
        ],
        [
            "guideName": "云归",
            "nameZh": "古驿道上的星辰",
            "nameEn": "Stars on the Ancient Trail",
            "descriptionZh": "沿着千年古驿道行走，感受前人的步履与今日的呼应。每一块驿站的石碑，都是穿越时空的低语。",
            "descriptionEn": "Walk along the ancient postal road, feeling the echo between past footsteps and present ones. Every stone marker is a whisper across time.",
            "difficulty": 3,
            "estimatedHours": 4.0,
            "totalDistance": 12.0,
            "isPremium": false,
            "nodes": [
                [
                    "order": 1,
                    "latitude": 34.4844,
                    "longitude": 113.0390,
                    "titleZh": "驿站遗址",
                    "titleEn": "Relay Station Ruins",
                    "contentZh": "这里曾是古代驿道的中转站。想象一下，千年前的行人也在此歇脚，望着同一片天空。你与他们之间，隔着时间，却共享着同一条路。",
                    "contentEn": "This was once a relay station on the ancient postal road. Imagine travelers a thousand years ago resting here, gazing at the same sky. Between you and them, time stretches—but you share the same path.",
                    "audioUrl": "https://example.com/audio5.mp3"
                ],
                [
                    "order": 2,
                    "latitude": 34.4944,
                    "longitude": 113.0490,
                    "titleZh": "古道尽头的诗",
                    "titleEn": "A Poem at the Trail's End",
                    "contentZh": "古人说「行到水穷处，坐看云起时」。走到这里，你已经不需要目的地了。路本身就是答案，行走本身就是归途。",
                    "contentEn": "The ancients said, 'Walk to where the waters end, sit and watch the clouds arise.' Having come this far, you no longer need a destination. The path itself is the answer; walking itself is the homecoming.",
                    "audioUrl": "https://example.com/audio6.mp3"
                ]
            ]
        ]
    ]

    // MARK: - Load Methods

    static func loadAllGuides() -> [Guide] {
        guides.map { data in
            let guide = Guide(
                name: data["name"] as! String,
                titleZh: data["titleZh"] as! String,
                titleEn: data["titleEn"] as! String
            )
            guide.bioZh = data["bioZh"] as? String ?? ""
            guide.bioEn = data["bioEn"] as? String ?? ""
            guide.avatarUrl = data["avatarUrl"] as? String
            guide.tags = data["tags"] as? [String] ?? []
            return guide
        }
    }

    static func loadConstellations(for guide: Guide) -> [Constellation] {
        constellations
            .filter { ($0["guideName"] as? String) == guide.name }
            .map { data in
                let c = Constellation(
                    guideId: guide.id,
                    nameZh: data["nameZh"] as! String,
                    nameEn: data["nameEn"] as! String
                )
                c.descriptionZh = data["descriptionZh"] as? String ?? ""
                c.descriptionEn = data["descriptionEn"] as? String ?? ""
                c.difficulty = data["difficulty"] as? Int ?? 1
                c.estimatedHours = data["estimatedHours"] as? Double ?? 0
                c.totalDistance = data["totalDistance"] as? Double ?? 0
                c.isPremium = data["isPremium"] as? Bool ?? false
                return c
            }
    }

    static func loadNodes(for constellation: Constellation) -> [ConstellationNode] {
        // 找到匹配的星图数据
        guard let constellationData = constellations.first(where: {
            ($0["nameZh"] as? String) == constellation.nameZh
        }),
        let nodesData = constellationData["nodes"] as? [[String: Any]] else {
            return []
        }

        return nodesData.map { data in
            let node = ConstellationNode(
                constellationId: constellation.id,
                order: data["order"] as? Int ?? 0
            )
            node.latitude = data["latitude"] as? Double ?? 0
            node.longitude = data["longitude"] as? Double ?? 0
            node.titleZh = data["titleZh"] as? String
            node.titleEn = data["titleEn"] as? String
            node.contentZh = data["contentZh"] as? String ?? ""
            node.contentEn = data["contentEn"] as? String ?? ""
            node.audioUrl = data["audioUrl"] as? String
            return node
        }
    }
}
