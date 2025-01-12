import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { TextBestBet } from './TextBestBet';
import { GraphicsBestBet } from './GraphicsBestBet';

interface BestBetsProps {
  recommendedBy: string;
  textBestBets?: {
    title: string;
    url: string;
    description: string;
  }[];
  graphicsBestBet?: {
    title: string;
    titleUrl?: string;
    imageUrl?: string;
    imageAltText?: string;
    links?: {
      title: string;
      url: string;
    }[];
  }
  parse(html: string): string | JSX.Element | JSX.Element[]; // eslint-disable-line no-undef
}

export const BestBets = ({ recommendedBy, textBestBets = [], graphicsBestBet, parse }: BestBetsProps) => {
  return (
    <>
      {(textBestBets?.length > 0 || graphicsBestBet) && (
        <GridContainer className="results-best-bets-wrapper">
          <Grid row gap="md" id="best-bets">
            <Grid col={true}>
              <GridContainer className='best-bets-title'>
                Recommended by {recommendedBy}
              </GridContainer>
              {textBestBets?.map((textBestBet, index) => {
                return (
                  <React.Fragment key={index}>
                    <TextBestBet
                      {...textBestBet}
                      parse={parse}
                    />
                  </React.Fragment>
                );
              })}
              {graphicsBestBet && (
                <GraphicsBestBet
                  {...graphicsBestBet}
                  parse={parse}
                />
              )}
            </Grid>
          </Grid>
        </GridContainer>
      )}
    </>
  );
};
