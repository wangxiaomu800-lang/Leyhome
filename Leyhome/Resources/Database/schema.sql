-- ============================================
-- 地脉归途 (Leyhome) - 数据库表结构
-- 版本: v1.0
-- 创建日期: 2026-01-26
-- 数据库: PostgreSQL + PostGIS (Supabase)
-- ============================================

-- 启用必要的扩展
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================
-- 1. 用户表 (users)
-- ============================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    apple_id TEXT UNIQUE,                    -- Apple ID 标识符
    google_id TEXT UNIQUE,                   -- Google ID 标识符
    nickname TEXT,                           -- 用户昵称
    avatar_url TEXT,                         -- 头像 URL
    bio TEXT,                                -- 个人简介
    total_distance DECIMAL DEFAULT 0,        -- 总行走距离（米）
    total_tracks INTEGER DEFAULT 0,          -- 总轨迹数
    total_nodes INTEGER DEFAULT 0,           -- 总心绪节点数
    subscription_status TEXT DEFAULT 'free', -- 订阅状态: free/premium
    subscription_expires_at TIMESTAMP,       -- 订阅过期时间
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_users_apple_id ON users(apple_id);
CREATE INDEX idx_users_google_id ON users(google_id);

-- ============================================
-- 2. 轨迹表 (tracks)
-- ============================================
CREATE TABLE tracks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    travel_mode TEXT NOT NULL,               -- 出行方式: walking/cycling/driving/flying
    started_at TIMESTAMP NOT NULL,           -- 开始时间
    ended_at TIMESTAMP,                      -- 结束时间
    duration INTEGER,                        -- 时长（秒）
    distance DECIMAL,                        -- 距离（米）
    path GEOGRAPHY(LINESTRING, 4326),        -- 轨迹路径（PostGIS地理类型）
    start_point GEOGRAPHY(POINT, 4326),      -- 起点坐标
    end_point GEOGRAPHY(POINT, 4326),        -- 终点坐标
    weather TEXT,                            -- 天气情况
    temperature DECIMAL,                     -- 温度
    is_synced BOOLEAN DEFAULT FALSE,         -- 是否已同步
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_tracks_user_id ON tracks(user_id);
CREATE INDEX idx_tracks_started_at ON tracks(started_at);
CREATE INDEX idx_tracks_path ON tracks USING GIST(path);

-- ============================================
-- 3. 心绪节点表 (nodes)
-- ============================================
CREATE TABLE nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    track_id UUID REFERENCES tracks(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    mood_type TEXT,                          -- 情绪类型: calm/joy/anxiety/relief/inspiration/nostalgia/gratitude
    content TEXT,                            -- 文字内容（最多500字）
    media_urls TEXT[],                       -- 媒体 URL 数组（图片/视频/音频）
    media_types TEXT[],                      -- 媒体类型数组: image/video/audio
    location GEOGRAPHY(POINT, 4326),         -- 节点位置
    address TEXT,                            -- 地址描述
    is_synced BOOLEAN DEFAULT FALSE,         -- 是否已同步
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_nodes_track_id ON nodes(track_id);
CREATE INDEX idx_nodes_user_id ON nodes(user_id);
CREATE INDEX idx_nodes_location ON nodes USING GIST(location);
CREATE INDEX idx_nodes_mood_type ON nodes(mood_type);

-- ============================================
-- 4. 圣迹表 (sacred_sites)
-- ============================================
CREATE TABLE sacred_sites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tier INTEGER NOT NULL,                   -- 层级: 1=源点圣迹, 2=地脉节点, 3=心绪锚点
    name_zh TEXT NOT NULL,                   -- 中文名称
    name_en TEXT NOT NULL,                   -- 英文名称
    description_zh TEXT,                     -- 中文描述
    description_en TEXT,                     -- 英文描述
    lore_zh TEXT,                            -- 中文地脉解读/传说
    lore_en TEXT,                            -- 英文地脉解读/传说
    location GEOGRAPHY(POINT, 4326) NOT NULL, -- 位置坐标
    address TEXT,                            -- 地址
    country TEXT,                            -- 国家
    region TEXT,                             -- 地区/省份
    image_url TEXT,                          -- 主图 URL
    gallery_urls TEXT[],                     -- 图库 URL 数组
    visit_count INTEGER DEFAULT 0,           -- 访问次数
    echo_count INTEGER DEFAULT 0,            -- 回响数量
    intention_count INTEGER DEFAULT 0,       -- 意向数量
    is_verified BOOLEAN DEFAULT TRUE,        -- 是否已验证
    discoverer_id UUID REFERENCES users(id), -- 发现者（仅用户提名的圣迹）
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_sacred_sites_tier ON sacred_sites(tier);
CREATE INDEX idx_sacred_sites_location ON sacred_sites USING GIST(location);
CREATE INDEX idx_sacred_sites_country ON sacred_sites(country);

-- ============================================
-- 5. 回响表 (echoes)
-- ============================================
CREATE TABLE echoes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID REFERENCES sacred_sites(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT,                            -- 文字内容（最多500字）
    media_urls TEXT[],                       -- 媒体 URL 数组
    media_types TEXT[],                      -- 媒体类型数组
    is_public BOOLEAN DEFAULT FALSE,         -- 是否公开
    is_anonymous BOOLEAN DEFAULT FALSE,      -- 是否匿名
    status TEXT DEFAULT 'pending',           -- 审核状态: pending/approved/rejected
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_echoes_site_id ON echoes(site_id);
CREATE INDEX idx_echoes_user_id ON echoes(user_id);
CREATE INDEX idx_echoes_status ON echoes(status);
CREATE INDEX idx_echoes_is_public ON echoes(is_public);

-- ============================================
-- 6. 意向表 (intentions)
-- ============================================
CREATE TABLE intentions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    site_id UUID REFERENCES sacred_sites(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    target_year INTEGER NOT NULL,            -- 目标年份
    target_month INTEGER NOT NULL,           -- 目标月份 (1-12)
    is_fulfilled BOOLEAN DEFAULT FALSE,      -- 是否已实现
    fulfilled_at TIMESTAMP,                  -- 实现时间
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(site_id, user_id, target_year, target_month)
);

-- 创建索引
CREATE INDEX idx_intentions_site_id ON intentions(site_id);
CREATE INDEX idx_intentions_user_id ON intentions(user_id);
CREATE INDEX idx_intentions_target ON intentions(target_year, target_month);

-- ============================================
-- 7. 先行者表 (guides)
-- ============================================
CREATE TABLE guides (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,                      -- 先行者姓名
    title_zh TEXT,                           -- 中文头衔
    title_en TEXT,                           -- 英文头衔
    bio_zh TEXT,                             -- 中文简介
    bio_en TEXT,                             -- 英文简介
    avatar_url TEXT,                         -- 头像 URL
    cover_url TEXT,                          -- 封面图 URL
    follower_count INTEGER DEFAULT 0,        -- 关注人数
    constellation_count INTEGER DEFAULT 0,   -- 星图数量
    is_verified BOOLEAN DEFAULT TRUE,        -- 是否认证
    is_active BOOLEAN DEFAULT TRUE,          -- 是否活跃
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 8. 星图表 (constellations)
-- ============================================
CREATE TABLE constellations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    guide_id UUID REFERENCES guides(id) ON DELETE CASCADE,
    name_zh TEXT NOT NULL,                   -- 中文名称
    name_en TEXT NOT NULL,                   -- 英文名称
    description_zh TEXT,                     -- 中文描述
    description_en TEXT,                     -- 英文描述
    cover_url TEXT,                          -- 封面图 URL
    track_count INTEGER DEFAULT 0,           -- 包含轨迹数量
    total_distance DECIMAL DEFAULT 0,        -- 总距离
    resonance_count INTEGER DEFAULT 0,       -- 共鸣次数
    is_premium BOOLEAN DEFAULT FALSE,        -- 是否付费内容
    is_published BOOLEAN DEFAULT TRUE,       -- 是否已发布
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_constellations_guide_id ON constellations(guide_id);
CREATE INDEX idx_constellations_is_premium ON constellations(is_premium);

-- ============================================
-- 9. 星图轨迹表 (constellation_tracks)
-- ============================================
CREATE TABLE constellation_tracks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    constellation_id UUID REFERENCES constellations(id) ON DELETE CASCADE,
    guide_id UUID REFERENCES guides(id) ON DELETE CASCADE,
    sequence INTEGER NOT NULL,               -- 顺序编号
    name_zh TEXT,                            -- 中文名称
    name_en TEXT,                            -- 英文名称
    description_zh TEXT,                     -- 中文描述
    description_en TEXT,                     -- 英文描述
    path GEOGRAPHY(LINESTRING, 4326),        -- 轨迹路径
    distance DECIMAL,                        -- 距离
    duration INTEGER,                        -- 预计时长（秒）
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_constellation_tracks_constellation_id ON constellation_tracks(constellation_id);

-- ============================================
-- 10. 星图节点表 (constellation_nodes)
-- ============================================
CREATE TABLE constellation_nodes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    track_id UUID REFERENCES constellation_tracks(id) ON DELETE CASCADE,
    guide_id UUID REFERENCES guides(id) ON DELETE CASCADE,
    mood_type TEXT,                          -- 情绪类型
    content_zh TEXT,                         -- 中文内容
    content_en TEXT,                         -- 英文内容
    audio_url TEXT,                          -- 音频 URL（先行者语音）
    media_urls TEXT[],                       -- 媒体 URL
    location GEOGRAPHY(POINT, 4326),         -- 位置
    trigger_radius DECIMAL DEFAULT 50,       -- 触发半径（米）
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_constellation_nodes_track_id ON constellation_nodes(track_id);
CREATE INDEX idx_constellation_nodes_location ON constellation_nodes USING GIST(location);

-- ============================================
-- 11. 寻迹申请表 (nominations)
-- ============================================
CREATE TABLE nominations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,                      -- 提名名称
    description TEXT NOT NULL,               -- 描述
    reason TEXT NOT NULL,                    -- 提名理由
    location GEOGRAPHY(POINT, 4326) NOT NULL, -- 位置
    address TEXT,                            -- 地址
    media_urls TEXT[] NOT NULL,              -- 媒体 URL（至少3张照片）
    reference_urls TEXT[],                   -- 参考资料 URL
    status TEXT DEFAULT 'pending',           -- 状态: pending/reviewing/approved/rejected
    reviewer_notes TEXT,                     -- 审核备注
    reviewed_at TIMESTAMP,                   -- 审核时间
    reviewer_id UUID,                        -- 审核人 ID
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_nominations_user_id ON nominations(user_id);
CREATE INDEX idx_nominations_status ON nominations(status);
CREATE INDEX idx_nominations_location ON nominations USING GIST(location);

-- ============================================
-- 12. 用户共鸣记录表 (user_resonances)
-- ============================================
CREATE TABLE user_resonances (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    constellation_id UUID REFERENCES constellations(id) ON DELETE CASCADE,
    constellation_track_id UUID REFERENCES constellation_tracks(id) ON DELETE CASCADE,
    user_track_id UUID REFERENCES tracks(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    is_completed BOOLEAN DEFAULT FALSE,
    reflection_node_id UUID REFERENCES nodes(id), -- 反思节点
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX idx_user_resonances_user_id ON user_resonances(user_id);
CREATE INDEX idx_user_resonances_constellation_id ON user_resonances(constellation_id);

-- ============================================
-- 13. 意向统计视图 (intention_stats)
-- ============================================
CREATE VIEW intention_stats AS
SELECT
    site_id,
    target_year,
    target_month,
    COUNT(*) as user_count
FROM intentions
GROUP BY site_id, target_year, target_month;

-- ============================================
-- 触发器：自动更新 updated_at
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sacred_sites_updated_at
    BEFORE UPDATE ON sacred_sites
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_guides_updated_at
    BEFORE UPDATE ON guides
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_constellations_updated_at
    BEFORE UPDATE ON constellations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- Row Level Security (RLS) 策略
-- ============================================

-- 启用 RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tracks ENABLE ROW LEVEL SECURITY;
ALTER TABLE nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE echoes ENABLE ROW LEVEL SECURITY;
ALTER TABLE intentions ENABLE ROW LEVEL SECURITY;
ALTER TABLE nominations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_resonances ENABLE ROW LEVEL SECURITY;

-- 用户只能访问自己的数据
CREATE POLICY "Users can view own data" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own data" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own tracks" ON tracks
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tracks" ON tracks
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view own nodes" ON nodes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own nodes" ON nodes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- 圣迹为公开数据
CREATE POLICY "Sacred sites are public" ON sacred_sites
    FOR SELECT USING (true);

-- 先行者和星图为公开数据
CREATE POLICY "Guides are public" ON guides
    FOR SELECT USING (true);

CREATE POLICY "Constellations are public" ON constellations
    FOR SELECT USING (true);

-- 公开的回响可以被所有人查看
CREATE POLICY "Public echoes are viewable" ON echoes
    FOR SELECT USING (is_public = true AND status = 'approved');

CREATE POLICY "Users can view own echoes" ON echoes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own echoes" ON echoes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 初始数据示例
-- ============================================

-- 插入示例源点圣迹 (Tier 1)
INSERT INTO sacred_sites (tier, name_zh, name_en, description_zh, description_en, lore_zh, lore_en, location, country, region, image_url)
VALUES
(1, '吉萨金字塔', 'Pyramids of Giza',
 '古埃及最著名的金字塔群，人类文明的奇迹',
 'The most famous pyramids of ancient Egypt, a wonder of human civilization',
 '金字塔是地球最古老的能量汇聚点之一，数千年来一直是地脉网络的核心枢纽。传说法老的灵魂通过这里升入星空，与宇宙能量融为一体。',
 'The pyramids are one of Earth''s oldest energy convergence points, serving as a core hub of the ley line network for thousands of years. Legend says the pharaoh''s soul ascended to the stars through here, merging with cosmic energy.',
 ST_GeogFromText('POINT(31.1342 29.9792)'),
 'Egypt', 'Giza', 'https://example.com/pyramids.jpg'),

(1, '马丘比丘', 'Machu Picchu',
 '印加帝国的失落之城，南美洲最神秘的遗迹',
 'The lost city of the Inca Empire, South America''s most mysterious ruins',
 '马丘比丘坐落在安第斯山脉的心脏地带，是地脉在南美大陆的最高能量汇聚点。印加人相信这里是天与地的交汇处，是与太阳神对话的圣地。',
 'Machu Picchu sits at the heart of the Andes, the highest energy convergence point of ley lines in South America. The Incas believed this was where heaven and earth met, a sacred place to commune with the Sun God.',
 ST_GeogFromText('POINT(-72.5450 -13.1631)'),
 'Peru', 'Cusco', 'https://example.com/machupicchu.jpg'),

(1, '巨石阵', 'Stonehenge',
 '英格兰的史前石圈，欧洲最神秘的新石器时代遗迹',
 'England''s prehistoric stone circle, Europe''s most mysterious Neolithic monument',
 '巨石阵是欧洲地脉网络的古老节点，数千年前的先民在此感知天体运行的奥秘。每逢夏至日出，阳光穿过巨石的缝隙，唤醒沉睡的大地能量。',
 'Stonehenge is an ancient node in Europe''s ley line network, where ancestors perceived celestial mysteries thousands of years ago. At summer solstice sunrise, light passes through the stones, awakening dormant earth energy.',
 ST_GeogFromText('POINT(-1.8262 51.1789)'),
 'United Kingdom', 'Wiltshire', 'https://example.com/stonehenge.jpg');

-- 完成
SELECT '数据库架构创建完成' as status;
