-- Supabase 数据库架构
-- 在 Supabase 中运行此 SQL 脚本来创建表

-- 禁用 RLS 以便测试（生产环境应启用）
-- 如果需要，可以启用 RLS 并设置相应的策略

-- 1. 创建用户表
CREATE TABLE IF NOT EXISTS public.users (
  id UUID NOT NULL PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  student_id TEXT UNIQUE,
  role TEXT NOT NULL DEFAULT '会員',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. 创建交易表
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  requester_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  finance_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  status TEXT NOT NULL DEFAULT '待处理',
  icon TEXT NOT NULL,
  receipt_path TEXT,
  is_approved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. 创建索引以提高查询性能
CREATE INDEX idx_transactions_requester_id ON public.transactions(requester_id);
CREATE INDEX idx_transactions_finance_id ON public.transactions(finance_id);
CREATE INDEX idx_transactions_date ON public.transactions(date);
CREATE INDEX idx_transactions_type ON public.transactions(type);

-- 4. 启用实时订阅
ALTER TABLE public.transactions REPLICA IDENTITY FULL;

-- 5. 示例数据（可选）
-- INSERT INTO public.users (id, email, name, role) VALUES
-- ('user-uuid-1', 'user1@example.com', '王大明', '會長'),
-- ('user-uuid-2', 'user2@example.com', '李小華', '財務');
