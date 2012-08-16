# coding: utf-8
require 'spec_helper'

describe UscisForm do
  before(:all) { FormAgency.destroy_all }

  describe '.import' do
    let(:forms_index_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/forms.html') }
    let(:forms_index_url) { 'http://www.uscis.gov/vgn-ext-templating/v/index.jsp?vgnextoid=db0' }
    let(:forms_file) { mock(File, :read => forms_index_page)}
    let(:form1_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form1.html') }
    let(:form1) { mock(File, :read => form1_landing_page) }
    let(:form2_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form2.html') }
    let(:form2) { mock(File, :read => form2_landing_page) }
    let(:form3_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form3.html') }
    let(:form3) { mock(File, :read => form3_landing_page) }
    let(:form4_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form4.html') }
    let(:form4) { mock(File, :read => form4_landing_page) }
    let(:instruction1_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/instruction1.html') }
    let(:instruction1) { mock(File, :read => instruction1_landing_page) }
    let(:instruction2_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/instruction2.html') }
    let(:instruction2) { mock(File, :read => instruction2_landing_page) }

    before do
      UscisForm.should_receive(:retrieve_forms_index_url).and_return(forms_index_url)
      UscisForm.should_receive(:open).with(forms_index_url).and_return(forms_file)
      UscisForm.should_receive(:open).
          with(%r[^http://www.uscis.gov/portal/site/uscis/menuitem.5af9bb95919f35e66f614176543f6d1a]).
          exactly(5).times.
          and_return(form1, form2, instruction1, form3, instruction2, form4)
    end

    context 'when there is no exisiting FormAgency' do
      before { UscisForm.import }

      it 'should create FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.name.should == 'uscis.gov'
        FormAgency.first.locale.should == 'en'
        FormAgency.first.display_name.should == 'U.S. Citizenship and Immigration Services'
      end
    end

    context 'when there is no existing Form' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'uscis.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Citizenship and Immigration Services')
      end

      before { UscisForm.import }

      it 'should not create a new FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.should == form_agency
      end

      it 'should create forms' do
        Form.count.should == 6
      end

      it 'should populate all the available fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'AR-11').first
        form.url.should == 'http://www.uscis.gov/files/form/ar-11.pdf'
        form.title.should == 'Change of Address'
        form.description.should =~ /\ATo report the change of address of an alien in the United States/
        form.landing_page_url.should == 'http://www.uscis.gov/ar-11'
        form.file_size.should == '370KB'
        form.file_type.should == 'PDF'
        form.number_of_pages.should == 1
        form.revision_date.should == '12/11/11'
      end

      it 'should handle latin characters' do
        Form.where(:form_agency_id => form_agency.id, :number => 'I-129F').first.title.should == 'Petition for Alien Fiancé(e)'
      end

      it 'should handle %b %Y revision date' do
        Form.where(:form_agency_id => form_agency.id, :number => 'EOIR-29').first.revision_date.should == 'April 2009'
      end

      it 'should handle number of pages in instruction form' do
        Form.where(:form_agency_id => form_agency.id, :number => 'I-539, Supplement A').first.number_of_pages.should == 2
      end

      it 'should handle %mm/%yy revision date' do
        Form.where(:form_agency_id => form_agency.id, :number => 'I-193').first.revision_date.should == '12/10'
      end
    end

    context 'when there is existing Form with the same agency and number' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'uscis.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Citizenship and Immigration Services')
      end

      let!(:existing_form) { Form.create!(:form_agency_id => form_agency.id,
                                          :number => 'AR-11',
                                          :url => 'http://www.uscis.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { UscisForm.import }

      it 'should create/update forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 6
      end

      it 'should update existing form' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'AR-11').first
        form.id.should == existing_form.id
      end
    end

    context 'when there is an obsolete Form from the same agency' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'uscis.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Citizenship and Immigration Services')
      end

      let!(:obsolete_form) { Form.create!(:form_agency_id => form_agency.id,
                                          :number => 'obsolete',
                                          :url => 'http://www.uscis.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { UscisForm.import }

      it 'should create forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 6
      end

      it 'should delete the obsolete form' do
        Form.find_by_id(obsolete_form.id).should be_nil
      end
    end
  end

  describe '.retrieve_forms_index_url' do
    let(:forms_index_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/forms.html') }
    let(:forms_index_url) { 'http://www.uscis.gov/vgn-ext-templating/v/index.jsp?vgnextoid=db0' }

    it 'should return form_index_url' do
      UscisForm.should_receive(:open).
          with('http://www.uscis.gov/portal/site/uscis').
          and_return(forms_index_page)
      UscisForm.retrieve_forms_index_url.should == forms_index_url
    end
  end
end
