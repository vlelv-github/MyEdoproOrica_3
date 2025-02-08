-- 타임 소티아리우스
local s,id=GetID()
function s.initial_effect(c)
	-- 1번 효과
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)	
	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_COIN_NEGATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.coincon)
	e2:SetOperation(s.coinop)
	c:RegisterEffect(e2)
end
    -- "시간의 마술사"의 카드명이 쓰여짐
s.listed_names={71625222}

function s.spfilter(c,e,tp)
	return c:IsCode(71625222) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local effs = {tc:GetOwnEffects()}
			local tg=nil
			local op=nil
			for k,eff in ipairs(effs) do
				if bit.band(eff:GetType(), EFFECT_TYPE_IGNITION)~=0 then
					tg=eff:GetTarget()
					op=eff:GetOperation()
				end
			end
			if tg~=nil then 
				
				-- 특수 소환한 "시간의 마술사"의 효과 발동
				local e1=Effect.CreateEffect(tc)
				e1:SetCategory(CATEGORY_COIN)
				e1:SetProperty(EFFECT_FLAG_DELAY)
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
				e1:SetCode(EVENT_SPSUMMON_SUCCESS)
				e1:SetTarget(tg)
				e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
					local e0=Effect.CreateEffect(tc)
					e0:SetType(EFFECT_TYPE_SINGLE)
					e0:SetCode(EFFECT_CANNOT_TRIGGER)
					e0:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					tc:RegisterEffect(e0)
					op(e,tp,eg,ep,ev,re,r,rp)
				end
				)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
			Duel.SpecialSummonComplete()
		end
	end
end

function s.coincon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and re:GetHandler():IsCode(71625222) and not Duel.HasFlagEffect(tp,id) 
end
function s.coinop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	if Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
		Duel.Hint(HINT_CARD,3,id)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.TossCoin(tp,ev)
	end
end