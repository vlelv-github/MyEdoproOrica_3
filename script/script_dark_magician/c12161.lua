-- 현혼의 마술사-블랙 매지션
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(CARD_DARK_MAGICIAN)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)

	-- 3번 효과
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetCountLimit(1,{id,1})
    e4:SetTarget(s.retg)
    e4:SetOperation(s.reop)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e5)
end
    -- "블랙 매지션", "블랙 매지션 걸"의 카드명이 쓰여짐
s.listed_names = {CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL}


function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsOriginalCodeRule(CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

function s.refilter(c,e)
	return c:IsReleasableByEffect() and c:IsCanBeEffectTarget(e)
end
function s.darkmagifilter(c,tp)
	return c:IsCode(CARD_DARK_MAGICIAN) and c:IsFaceup()
end
function s.recon(sg,e,tp,mg)
	return sg:IsExists(s.darkmagifilter,1,nil,tp)
end
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.rmvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local g=aux.SelectUnselectGroup(g,e,tp,2,2,s.recon,1,tp,HINTMSG_RELEASE)
	Duel.SetTargetCard(g)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1250)
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1250)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetTargetCards(e)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if #tg>0 and Duel.Release(tg,REASON_EFFECT) then
		Duel.Damage(p,d,REASON_EFFECT)
	end
end