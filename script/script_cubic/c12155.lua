-- 방계영역
local s,id=GetID()
function s.initial_effect(c)
	-- 발동
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- 2번 효과
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(function(_,tp,eg) return eg:IsExists(s.nsconfilter,1,nil,tp) end)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)

	-- 3번 효과
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
	-- "방계" 테마명이 쓰여짐
s.listed_series = {0xe3}
	-- "방계윤 비잠"의 카드명이 쓰여짐
s.listed_names = {15610297}
	-- 1번 효과
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsSpellTrap() and c:IsSetCard(0xe3) and not c:IsCode(id)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end

	-- 2번 효과
function s.nsconfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0xe3) and not c:IsReason(REASON_DRAW)
end
function s.filter0(c)
	return c:IsCode(15610297) and c:IsFaceup()
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xe3) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and not c:IsSummonableCard()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter0,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*200)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- "방계윤 비잠"을 전부 묘지로
	local g=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_ONFIELD,0,nil)
	if #g==0 then return end
	local gg=Duel.SendtoGrave(g,REASON_EFFECT)
	if gg==0 then return end
	if Duel.Damage(1-tp,gg * 200,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
		local effs = {tc:GetOwnEffects()}
		for k,eff in ipairs(effs) do
			if eff:GetCode()==EFFECT_SPSUMMON_PROC then
				eff:SetLabelObject(Group.CreateGroup())
				local op = eff:GetOperation()
				if op and tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then 
					op(eff,tp,eg,ep,ev,re,r,rp,0)
				end
				Duel.SpecialSummonComplete()
			end
		end
	end
end

-- 3번 효과
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not eg then return end
	for rc in aux.Next(eg) do
		if rc:IsStatus(STATUS_OPPO_BATTLE) then
			if rc:IsRelateToBattle() then
				if rc:IsControler(tp) and rc:IsSetCard(0xe3) then 
					e:SetLabelObject(rc)
					return true end
			else
				if rc:IsPreviousControler(tp) and rc:IsPreviousSetCard(0xe3) then 
					e:SetLabelObject(rc)
					return true end
			end
		end
	end
	return false
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local att=e:GetLabelObject():GetBattleTarget():GetBaseAttack()
	if att<0 then att=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(att)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,att)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
