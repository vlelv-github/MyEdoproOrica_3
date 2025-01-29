-- 웜 터미널
local s,id=GetID()
function s.initial_effect(c)
	-- 소생 제한
	c:EnableReviveLimit()
	-- 융합 소재
	Fusion.AddProcMixRep(c,true,true,s.mfilter2,1,3,s.mfilter1)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2)
	e2:SetCondition(s.chcon)
	e2:SetTarget(s.chtg)
	e2:SetOperation(s.chop)
	c:RegisterEffect(e2)
	-- 3번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.contg)
	e3:SetOperation(s.conop)
	c:RegisterEffect(e3)
end
	-- "웜"의 테마명이 쓰여짐
s.listed_series = {0x3e}

function s.mfilter1(c,sc,st,tp)
	return c:IsRace(RACE_REPTILE,sc,st,tp) and c:IsSetCard(0x3e,sc,st,tp)
end
function s.mfilter2(c,sc,st,tp)
	return c:IsRace(RACE_REPTILE,sc,st,tp)
end

function s.matcheck(e,c)
	local ct=c:GetMaterial()
	if #ct>0 then
		local ae=Effect.CreateEffect(c)
		ae:SetType(EFFECT_TYPE_SINGLE)
		ae:SetCode(EFFECT_SET_BASE_ATTACK)
		ae:SetValue(#ct*1000)
		ae:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE-RESET_TOFIELD)
		c:RegisterEffect(ae)
	end
end
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return #g>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,s.repop)
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(s.spfilter),1-tp,LOCATION_GRAVE,0,1,1,nil,e,1-tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end

function s.confilter(c)
	return c:IsAbleToChangeControler() and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.confilter,tp,0,LOCATION_MZONE,nil)
	local mz=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)
	if chk==0 then return g and math.min(#g,mz) > 0 end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetMatchingGroup(s.confilter,tp,0,LOCATION_MZONE,nil)
	local mz=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)
	if mz < #tg then 
		tg = tg:Select(tp,mz,mz,nil)
	end
	if #tg>0 then 
		for sc in aux.Next(tg) do
			Duel.GetControl(sc,tp)
			-- 파충류족 취급
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_RACE)
			e1:SetValue(RACE_REPTILE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
end