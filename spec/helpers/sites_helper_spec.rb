require 'spec_helper'

describe SitesHelper do
  describe "#daily_snapshot_toggle(membership)" do
    context 'when membership is nil' do
      it 'should return nil' do
        helper.daily_snapshot_toggle(nil).should be_nil
      end
    end
  end

  describe '#user_row_css_class_hash' do
    let(:approval_status) { example.metadata[:approval_status] }
    let(:user) { mock_model(User, approval_status: approval_status) }
    let(:subject) { helper.user_row_css_class_hash(user) }

    context 'when User has', approval_status: 'pending_email_verification' do
      specify { expect(subject).to eq(class: 'warning') }
    end

    context 'when User has', approval_status: 'pending_approval' do
      specify { expect(subject).to eq(class: 'warning') }
    end

    context 'when User has', approval_status: 'not_approved' do
      specify { expect(subject).to eq(class: 'error') }
    end
  end

  describe "preview_main_nav_item" do
    let(:affiliate) { mock_model(Affiliate, name: 'somename', search_consumer_search_enabled: dese, force_mobile_format?: fmf) }
    let(:subject) { helper.preview_main_nav_item(affiliate, 'sometitle') }

    context 'when the search_consumer_search_enabled flag is true' do
      let(:dese) { true }
      let(:fmf) { false }
      specify { expect(subject).to eq(main_nav_item 'sometitle', search_consumer_search_url(affiliate: affiliate.name), 'fa-eye', [], target: '_blank') }
    end

    context 'when the search_consumer_search_enabled flag is false' do
      let(:dese) { false }

      context 'when the force_mobile_format flag is true' do
        let(:fmf) { true }
        specify { expect(subject).to eq(main_nav_item 'sometitle', search_url(protocol: 'http', affiliate: affiliate.name), 'fa-eye', [], target: '_blank') }
      end

      context 'when the force_mobile_format flag is false' do
        let(:fmf) { false }
        specify { expect(subject).to eq(main_nav_item 'sometitle', site_preview_path(affiliate), 'fa-eye', [], preview_serp_link_options) }
      end
    end
  end

  describe "#generate_jwt" do
    let(:affiliate) { mock_model(Affiliate, id: 491, name: 'somename', display_name: 'Somename Displayed', api_access_key: 'somekey') }
    let(:subject) { helper.generate_jwt(affiliate) }
    it 'should be decryptable using the JWT secret' do
      expect(subject).to be_kind_of(String)
      decoded = JWT.decode subject, JWT_SECRET, 'HS256'
      expect(decoded).to be_kind_of(Array)
      payload = decoded[0]
      expect(payload['affiliateName']).to eq('somename')
      expect(payload['affiliateDisplayName']).to eq('Somename Displayed')
      expect(payload['affiliateUsasearchId']).to eq(491)
      expect(payload['accessKey']).to eq('somekey')
      expect(payload['exp']).to be
    end
  end
end
