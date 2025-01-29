-- 영혼의 가디언 에아토스
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
	e2:SetValue(34022290)
	c:RegisterEffect(e2)
	-- 3번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetHintTiming(TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
    -- "가디언 에아토스", "여신의 성검-에아토스"의 카드명이 쓰여짐
s.listed_names = {34022290, 55569674}
	-- 장착 마법 카드 선언 필터
s.announce_filter={TYPE_EQUIP,OPCODE_ISTYPE}
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and (not Duel.IsExistingMatchingCard(Card.IsMonster,c:GetControler(),LOCATION_GRAVE,0,1,nil)
		or Duel.IsExistingMatchingCard(Card.IsCode,c:GetControler(),LOCATION_ONFIELD,0,1,nil,55569674))
end

function s.eqfilter(c)
	return c:IsMonster()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.eqfilter(chkc) 
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	if chk==0 then return Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) 
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	local ac=Duel.AnnounceCard(tp,s.announce_filter)
	e:SetLabel(ac)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.eqtcfilter(c,ec)
	return c:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local ac=e:GetLabel()
	if not ac then return end
	local tc=Duel.GetFirstTarget()
	if not tc then return end
	local eqtc=Duel.SelectMatchingCard(tp,s.eqtcfilter,tp,LOCATION_MZONE,0,1,1,nil,tc):GetFirst()
	if Duel.Equip(tp,tc,eqtc,true) then 
		--Equip limit
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(function(e,c) return c==e:GetLabelObject() end)
		e1:SetLabelObject(eqtc)
		tc:RegisterEffect(e1)
		-- 선언한 카드명으로 변경
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(ac)
		tc:RegisterEffect(e2)
	end
end
